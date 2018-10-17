use strict;
use warnings;

use Test::More;
plan tests => 12;

use HTTP::Status qw(status_message status_message_with_fallback);

foreach my $code (100, 200, 300, 400, 500) {
    is(status_message_with_fallback($code), status_message($code));
}

is(status_message_with_fallback(0), undef);
is(status_message_with_fallback(199), "OK");
is(status_message_with_fallback(299), "OK");
is(status_message_with_fallback(399), "Redirect");
is(status_message_with_fallback(499), "Client Error");
is(status_message_with_fallback(599), "Server Error");
is(status_message_with_fallback(600), undef);
