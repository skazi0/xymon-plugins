#!/usr/bin/perl
use strict;
use warnings;
use Hobbit;
use LWP::Simple;
use HTML::TreeBuilder::XPath;

my $ip = $ARGV[0];
my $host = $ARGV[1];

my $bb = new Hobbit({'test' => 'pf', 'hostname' => $host});
my $trends = Hobbit::trends($host);

my $ua = LWP::UserAgent->new(cookie_jar => {}, ssl_opts => {verify_hostname => 0, SSL_verify_mode => 0x00});
my $res;

# get password
my $user = 'xymon';
my $password = &get_password($host, $user);

# load page to get CSRF token
$res = $ua->get("https://$host/");
my $html = HTML::TreeBuilder::XPath->new;
$html->parse($res->content);
my $csrf = $html->findvalue('//input[@name="__csrf_magic"]/@value');

# login
$res = $ua->post("https://$host/", {usernamefld => $user, passwordfld => $password, login => '', __csrf_magic => $csrf});
if ($res->is_error)
{
    $bb->color_line('red', 'login failed: ' . $res->status_line);
}
else
{
    # get status
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

#       updateUptime(values[2]);
#       updateDateTime(values[5]);
#       updateCPU(values[0]);
#       updateMemory(values[1]);
#       updateState(values[3]);
#       updateTemp(values[4]);
#       updateInterfaceStats(values[6]);
#       updateInterfaces(values[7]);
#       updateCpuFreq(values[8]);
#       updateLoadAverage(values[9]);
#       updateMbuf(values[10]);
#       updateMbufMeter(values[11]);
#       updateStateMeter(values[12]);
    }
}

$bb->send;
$trends->send;

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
