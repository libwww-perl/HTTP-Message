use strict;
use warnings;

use Test::More;
plan tests => 11;

use HTTP::Status qw(:constants :is status_message);

is(HTTP_OK, 200);

ok(is_info(HTTP_CONTINUE));
ok(is_success(HTTP_ACCEPTED));
ok(is_error(HTTP_BAD_REQUEST));
ok(is_client_error(HTTP_I_AM_A_TEAPOT));
ok(is_redirect(HTTP_MOVED_PERMANENTLY));
ok(is_redirect(HTTP_PERMANENT_REDIRECT));

ok(!is_success(HTTP_NOT_FOUND));

is(status_message(0), undef);
is(status_message(200), "OK");

my %status_code = HTTP::Status::status_code();
is($status_code{200}, status_message(200));
