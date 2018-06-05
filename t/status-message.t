use strict;
use warnings;

use Test::More;

use HTTP::Status qw(status_message);

is(status_message(0), undef);
is(status_message(199), "OK");
is(status_message(299), "OK");
is(status_message(399), "Redirect");
is(status_message(499), "Client Error");
is(status_message(599), "Server Error");
is(status_message(600), undef);


is(status_message(404), "Not Found", "Found the 404");

done_testing;
