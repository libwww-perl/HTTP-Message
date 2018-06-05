use strict;
use warnings;

use Test::More;
plan tests => 9;

use HTTP::Status qw(status_message);

is(status_message(0), undef);
is(status_message(100), "Continue");
is(status_message(199), "OK");
is(status_message(299), "OK");
is(status_message(399), "Redirect");
is(status_message(499), "Client Error");
is(status_message(504), "Gateway Timeout");
is(status_message(599), "Server Error");
is(status_message(600), undef);
