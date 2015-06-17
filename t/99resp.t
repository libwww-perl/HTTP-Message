#!perl -w

# Test extra HTTP::Response methods.  Basic operation is tested in the
# message.t test suite and response.t test suite

use strict;
use Test;
plan tests => 13;

use HTTP::Date;
use HTTP::Request;
use HTTP::Response;

my $time = time;

my $req = HTTP::Request->new(GET => 'http://www.sn.no');
my $r = new HTTP::Response 200, 'OK';

ok($r->is_redirect, '');
ok($r->is_error, '');
ok($r->is_client_error, '');
ok($r->is_server_error, '');
ok($r->is_info, '');
ok($r->filename, undef);

$r = new HTTP::Response 302, "Found";
$r->request($req);
ok($r->is_redirect, 1);

# basic header with an ascii filename defined
$r->push_header('Content-Disposition', 'attachment; filename="fname.ext"');
ok($r->filename, 'fname.ext');

# incorrect header that has no filename defined
$r->remove_header('Content-Disposition');
$r->push_header('Content-Disposition', 'attachment;');
ok($r->filename, undef);

# incorrect header that has no filename defined, but does have a filename field
$r->remove_header('Content-Disposition');
$r->push_header('Content-Disposition', 'attachment; filename=""');
ok($r->filename, undef);

# Q is quoted printable encoding type, filename() should return 'a'
$r->remove_header('Content-Disposition');
$r->push_header('Content-Disposition', 'attachment; filename="=?ISO-8859-1?Q?a?="');
ok($r->filename, 'a');

# B is base64 encoding type, filename() should return  'a'
$r->remove_header('Content-Disposition');
$r->push_header('Content-Disposition', 'attachment; filename="=?ISO-8859-1?B?YQ=?="');
ok($r->filename, 'a');

# K is not a valid encoding type, filename() should return undef
$r->remove_header('Content-Disposition');
$r->push_header('Content-Disposition', 'attachment; filename="=?ISO-8859-1?K?YQ=?="');
ok($r->filename, undef);

