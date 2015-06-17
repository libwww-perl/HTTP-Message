#!perl -w

# Test extra HTTP::Response methods.  Basic operation is tested in the
# message.t test suite and response.t test suite

use strict;
use Test;
plan tests => 89;

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

$r = new HTTP::Response 100, "Continue";
$r->request($req);
ok($r->is_info, 1);

$r = new HTTP::Response 101, "Switching Protocols";
$r->request($req);
ok($r->is_info, 1);

$r = new HTTP::Response 102, "Processing";
$r->request($req);
ok($r->is_info, 1);



# is_success() for 2xx series of responses ... goes here.

$r = new HTTP::Response 200, "OK";
$r->request($req);
ok($r->is_success, 1);

$r = new HTTP::Response 201, "Created";
$r->request($req);
ok($r->is_success, 1);

$r = new HTTP::Response 202, "Accepted";
$r->request($req);
ok($r->is_success, 1);

$r = new HTTP::Response 203, "Non-Authoritative Information";
$r->request($req);
ok($r->is_success, 1);

$r = new HTTP::Response 204, "No Content";
$r->request($req);
ok($r->is_success, 1);

$r = new HTTP::Response 205, "Reset Content";
$r->request($req);
ok($r->is_success, 1);

$r = new HTTP::Response 206, "Partial Content";
$r->request($req);
ok($r->is_success, 1);

$r = new HTTP::Response 207, "Multi-Status";
$r->request($req);
ok($r->is_success, 1);

$r = new HTTP::Response 208, "Already Reported";
$r->request($req);
ok($r->is_success, 1);

$r = new HTTP::Response 226, "IM Used";
$r->request($req);
ok($r->is_success, 1);


$r = new HTTP::Response 300, "Multiple Choices";
$r->request($req);
ok($r->is_redirect, 1);

$r = new HTTP::Response 301, "Moved Permanently";
$r->request($req);
ok($r->is_redirect, 1);

$r = new HTTP::Response 302, "Found";
$r->request($req);
ok($r->is_redirect, 1);

$r = new HTTP::Response 303, "See Other";
$r->request($req);
ok($r->is_redirect, 1);

$r = new HTTP::Response 304, "Not Modified";
$r->request($req);
ok($r->is_redirect, 1);

$r = new HTTP::Response 305, "Use Proxy";
$r->request($req);
ok($r->is_redirect, 1);

$r = new HTTP::Response 306, "Switch Proxy";
$r->request($req);
ok($r->is_redirect, 1);

$r = new HTTP::Response 307, "Temporary Redirect";
$r->request($req);
ok($r->is_redirect, 1);

$r = new HTTP::Response 308, "Permanent Redirect";
$r->request($req);
ok($r->is_redirect, 1);


$r = new HTTP::Response 400, "Bad Request";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 401, "Unauthorized";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 402, "Payment Required";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 403, "Forbidden";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 404, "Not Found";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 405, "Method Not Allowed";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 406, "Not Acceptable";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 407, "Proxy Authentication Required";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 408, "Request Timeout";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 409, "Conflict";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 410, "Gone";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 411, "Length Required";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 412, "Precondition Failed";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 413, "Request Entity Too Large";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 414, "Request-URI Too Long";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 415, "Unsupported Media Type";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 416, "Request Range Not Satisfiable";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 417, "Expectation Failed";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 418, "I'm a teapot";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 419, "Authentication Timeout";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 420, "Method Failure";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 421, "Misdirected Request";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 422, "Unprocessable Entity";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 423, "Locked";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 424, "Failed Dependency";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 428, "Precondition Required";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 429, "Too Many Requests";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 431, "Request Header Fields Too Large";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 440, "Login Timeout";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 444, "No Response";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 449, "Retry With";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 450, "Blocked by Windows Parental Controls";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 451, "Redirect";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 451, "Unavailable For Legal Reasons";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 494, "Request Header Too Large";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 495, "Cert Error";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 496, "No Cert";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 497, "HTTP to HTTPS";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 498, "Token expired/invalid";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 499, "Client Closed Request";
$r->request($req);
ok($r->is_client_error, 1);

$r = new HTTP::Response 499, "Token required";
$r->request($req);
ok($r->is_client_error, 1);


$r = new HTTP::Response 500, "Internal Server Error";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 501, "Not Implemented";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 502, "Bad Gateway";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 503, "Service Unavailable";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 504, "Gateway Timeout";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 505, "HTTP Version Not Supported";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 506, "Variant Also Negotiates";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 507, "Insufficient Storage";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 508, "Loop Detected";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 509, "Bandwidth Limit Exceeded";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 510, "Not Extended";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 511, "Network Authentication Required";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 598, "Network read timeout error";
$r->request($req);
ok($r->is_server_error, 1);

$r = new HTTP::Response 599, "Network connect timeout error";
$r->request($req);
ok($r->is_server_error, 1);




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

