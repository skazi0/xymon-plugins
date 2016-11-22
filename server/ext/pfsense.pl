#!/usr/bin/perl
use strict;
use warnings;
use Hobbit;
use LWP::Simple;
use HTML::TreeBuilder::XPath;

my $ip = $ARGV[0];
my $host = $ARGV[1];

my $bb = new Hobbit({'test' => 'pf', 'hostname' => $host});

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
}

$bb->send;

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
