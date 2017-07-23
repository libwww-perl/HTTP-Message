use strict;
use warnings;

use Test::More;
plan tests => 20;

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

ok(!is_info(HTTP_NOT_FOUND));
ok(!is_success(HTTP_NOT_FOUND));
ok(!is_redirect(HTTP_NOT_FOUND));
ok(!is_error(HTTP_CONTINUE));
ok(!is_client_error(HTTP_CONTINUE));
ok(!is_server_error(HTTP_NOT_FOUND));
ok(!is_server_error(999));
ok(!is_info(99));
ok(!is_success(99));
ok(!is_redirect(99));
