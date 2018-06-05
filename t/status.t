use strict;
use warnings;

use Test::More;
plan tests => 39;

use HTTP::Status qw(:constants :is status_message);

is(HTTP_OK, 200);

ok(is_info(HTTP_CONTINUE));
ok(is_success(HTTP_ACCEPTED));
ok(is_error(HTTP_BAD_REQUEST));
ok(is_client_error(HTTP_I_AM_A_TEAPOT));
ok(is_redirect(HTTP_MOVED_PERMANENTLY));
ok(is_redirect(HTTP_PERMANENT_REDIRECT));

ok(!is_success(HTTP_NOT_FOUND));

is(status_message(  0), undef);
is(status_message(200), "OK");
is(status_message(404), "Not Found");
is(status_message(999), undef);


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

ok(is_cacheable_by_default($_),
  "Cacheable by default [$_] " . status_message($_)
) for (200,203,204,206,300,301,404,405,410,414,451,501);

ok(!is_cacheable_by_default($_),
  "... is not cacheable [$_] " . status_message($_)
) for (100,201,302,400,500);
