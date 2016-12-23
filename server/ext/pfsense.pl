#!/usr/bin/perl
use strict;
use warnings;
use Hobbit;
use LWP::Simple;
use HTML::TreeBuilder::XPath;

my $ip = $ARGV[0];
my $host = $ARGV[1];

my $commahost = $host; $commahost =~ s/\./,/g;

my $bb = new Hobbit({'test' => 'pf', 'hostname' => $host});
my $trends = Hobbit::trends($host);
my $client = new Hobbit({'test' => 'freebsd', 'type' => 'client', 'hostname' => $commahost});

my $ua = LWP::UserAgent->new(cookie_jar => {}, ssl_opts => {verify_hostname => 0, SSL_verify_mode => 0x00});
my $res;

# get password
my $user = 'xymon';
my $password = &get_password($host, $user);

# load page to get CSRF token
$res = $ua->get("https://$host/");
my $html = HTML::TreeBuilder::XPath->new_from_content($res->content);
my $csrf = $html->findvalue('//input[@name="__csrf_magic"]/@value');

# login
$res = $ua->post("https://$host/", {usernamefld => $user, passwordfld => $password, login => '', __csrf_magic => $csrf});
if ($res->is_error)
{
    $bb->color_line('red', 'login failed: ' . $res->status_line);
}
else
{
    # update csrf token
    $res = $ua->get("https://$host/diag_system_activity.php");
    if ($res->is_error)
    {
        $bb->color_line('red', 'request4 failed: ' . $res->status_line);
        die;
    }
    else
    {
        $html = HTML::TreeBuilder::XPath->new_from_content($res->content);
        $csrf = $html->findvalue('//script[contains(text(), "var csrfMagicToken")]/text()');
        # extract value
        $csrf =~ s/.*var\s+csrfMagicToken\s*=\s*"([^"]+)".*/$1/; # "
    }

    # get system activity
    $res = $ua->post("https://$host/diag_system_activity.php", {getactivity => 'yes', __csrf_magic => $csrf});
    if ($res->is_error)
    {
        $bb->color_line('red', 'request3 failed: ' . $res->status_line);
        die;
    }
    else
    {
        $client->print("[top]\n");
        my $topstr = $res->content;
        $client->print($topstr);

        my $upstr = '';
        my $loadstr = '';
        my $timestr = '';

        for my $line (split(/[\n\r]+/, $topstr))
        {
            if ($line =~ /(load averages:\s*[\d\.]+,\s*[\d\.]+,\s*[\d\.]+)/)
            {
                $loadstr = $1;
            }
            if ($line =~ / (up (?:\d+\+)?[\d\.]+:[\d\.]+):[\d\.]+\s+(\d+:\d+:\d+)/)
            {
                $upstr = $1;
                $timestr = $2;

                $upstr =~ s/\+/ days /;
            }
        }
        $client->print("[uptime]\n");
        $client->print("$timestr $upstr, $loadstr\n");
    }

    # get other stats
    $res = $ua->get("https://$host/getstats.php");
    if ($res->is_error)
    {
        $bb->color_line('red', 'request2 failed: ' . $res->status_line);
        die;
    }
    else
    {
        my @stats = split(/\|/, $res->content);

        # updateUptime(values[2]);
        # updateLoadAverage(values[9]);

        # updateDateTime(values[5]);
        $client->print("[date]\n");
        $client->print($stats[5]."\n");

        # for some reason [date] can't be the last section or the cpu status will be incorrectly generated
        $client->print("[dummy]\n");

#       updateCPU(values[0]);
#print "cpu:".$stats[0]."\n";

        # updateMemory(values[1]);
        $trends->print("[memory.actual.rrd]\n");
        $trends->sprintf("DS:realmempct:GAUGE:600:0:U %g\n", $stats[1]);
        $trends->print("[memory.real.rrd]\n");
        $trends->sprintf("DS:realmempct:GAUGE:600:0:U U\n");
        # no swap info in getstats output
        $trends->print("[memory.swap.rrd]\n");
        $trends->sprintf("DS:realmempct:GAUGE:600:0:U U\n");

        # updateState(values[3]);
        # updateStateMeter(values[12]); # percent recalcualted below
        my ($statesUsed, $statesMax) = split(/\//, $stats[3]);
        $trends->print ("[states.rrd]\n");
        $trends->sprintf ("DS:used:GAUGE:600:U:U %d\n", $statesUsed);
        $trends->sprintf ("DS:max:GAUGE:600:U:U %d\n", $statesMax);
        $trends->sprintf ("DS:usedpct:GAUGE:600:U:U %g\n", 100. * $statesUsed / $statesMax);

#       updateTemp(values[4]);
#       updateInterfaceStats(values[6]);
#       updateInterfaces(values[7]);
#       updateCpuFreq(values[8]);

        # updateMbuf(values[10]);
        # updateMbufMeter(values[11]); # percent recalculated below
        my ($mbufUsed, $mbufMax) = split(/\//, $stats[10]);
        $trends->print ("[mbuf.rrd]\n");
        $trends->sprintf ("DS:used:GAUGE:600:U:U %d\n", $mbufUsed);
        $trends->sprintf ("DS:max:GAUGE:600:U:U %d\n", $mbufMax);
        $trends->sprintf ("DS:usedpct:GAUGE:600:U:U %g\n", 100. * $mbufUsed / $mbufMax);
    }

    # get update status
    $res = $ua->get("https://$host/widgets/widgets/system_information.widget.php?getupdatestatus=1");

    if ($res->is_error)
    {
        $bb->color_line('red', 'request failed: ' . $res->status_line);
        die;
    }
    else
    {
        my $pf_status = $res->content;
        if ($pf_status =~ /The system is on the latest version/)
        {
            $bb->add_color ('green');
        }
        else
        {
            $bb->add_color ('red');
        }

        $bb->print($pf_status);
    }

    # get interface name -> descr mapping
    my %ifmap;
    $res = $ua->get("https://$host/widgets/widgets/interfaces.widget.php");
    if ($res->is_error)
    {
        $bb->color_line('red', 'request failed: ' . $res->status_line);
        die;
    }
    else
    {
        my $html = HTML::TreeBuilder::XPath->new;
        $html->parse($res->content);
        my $iflinks = $html->findnodes('//a');
        foreach my $iflink (@{$iflinks})
        {
            my $ifdescr = $iflink->as_trimmed_text;
            my ($ifname) = ($iflink->attr('href') =~ /\?if=(.*)/);
            $ifmap{$ifname} = $ifdescr;
        }
    }

    # get interface stats
    foreach my $ifname (keys %ifmap)
    {
        $res = $ua->get("https://$host/ifstats.php?if=$ifname");
        if ($res->is_error)
        {
            $bb->color_line('red', 'request failed: ' . $res->status_line);
            die;
        }
        else
        {
            my $text = $res->content;
            chomp $text;
            my @parts = split(/\|/, $text);
            die unless (scalar @parts == 3);

            my $name = $ifmap{$ifname};
            $trends->print ("[ifstat,$name.rrd]\n");
            $trends->sprintf ("DS:bytesReceived:DERIVE:600:0:U %d\n", int($parts[1]));
            $trends->sprintf ("DS:bytesSent:DERIVE:600:0:U %d\n", int($parts[2]));
        }
    }
}

$bb->send;
$trends->send;
$client->send;

sub text2bytes
{
    my @parts = split(/\s/, shift);

    return $parts[0] * 1024. * 1024. * 1024. if ($parts[1] eq 'GiB');
    return $parts[0] * 1024. * 1024. if ($parts[1] eq 'MiB');
    return $parts[0] * 1024. if ($parts[1] eq 'KiB');
    return $parts[0] * 1.;
}

sub get_password
{
    my $host = shift;
    my $user = shift;
    my $pass;

    open(IN, "<$ENV{XYMONHOME}/etc/pfsensepasswd") or die "cannot open password file";

    while (<IN>)
    {
        chomp;
        my @parts = split /:/;
        if ($parts[0] eq $host and $parts[1] eq $user)
        {
            $pass = $parts[2];
            last;
        }
    }

    close IN;

    return $pass;
}
