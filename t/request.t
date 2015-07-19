# Test extra HTTP::Request methods.  Basic operation is tested in the
# message.t test suite.

use strict;
use warnings;

use Test::More;
plan tests => 11;

use HTTP::Request;

my $req = HTTP::Request->new(GET => "http://www.example.com");
$req->accept_decodable;

is($req->method, "GET");
is($req->uri, "http://www.example.com");
like($req->header("Accept-Encoding"), qr/\bgzip\b/);  # assuming IO::Uncompress::Gunzip is there

$req->dump(prefix => "# ");

is($req->method("DELETE"), "GET");
is($req->method, "DELETE");

is($req->uri("http:"), "http://www.example.com");
is($req->uri, "http:");

$req->protocol("HTTP/1.1");

my $r2 = HTTP::Request->parse($req->as_string);
is($r2->method, "DELETE");
is($r2->uri, "http:");
is($r2->protocol, "HTTP/1.1");
is($r2->header("Accept-Encoding"), $req->header("Accept-Encoding"));
