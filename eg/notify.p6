use v6;

use lib;
use Growl::GNTP;

my $a = Growl::GNTP.new;
$a.register(
    AppName => 'gntp-send',
    Notifications => [
		{Name => 'default'},
    ]
);
$a.notify(
	AppName => 'gntp-send',
	Name => 'default',
	Title => 'blah',
	Text => 'BLAH',
);
