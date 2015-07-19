use strict;
use warnings;

use Test::More;
plan tests => 8;

use HTTP::Status;

is(RC_OK, 200);

ok(is_info(RC_CONTINUE));
ok(is_success(RC_ACCEPTED));
ok(is_error(RC_BAD_REQUEST));
ok(is_redirect(RC_MOVED_PERMANENTLY));

ok(!is_success(RC_NOT_FOUND));

is(status_message(0), undef);
is(status_message(200), "OK");
