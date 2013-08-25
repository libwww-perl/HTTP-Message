# Test extra HTTP::Request methods.  Basic operation is tested in the
# message.t test suite.

use strict;

use Test;
plan tests => 16;

use HTTP::Request;

my $req = HTTP::Request->new(GET => "http://www.example.com");
$req->accept_decodable;

ok($req->method, "GET");
ok($req->uri, "http://www.example.com");
ok($req->header("Accept-Encoding") =~ /\bgzip\b/);  # assuming IO::Uncompress::Gunzip is there

$req->dump(prefix => "# ");

ok($req->method("DELETE"), "GET");
ok($req->method, "DELETE");

ok($req->uri("http:"), "http://www.example.com");
ok($req->uri, "http:");

$req->protocol("HTTP/1.1");

my $r2 = HTTP::Request->parse($req->as_string);
ok($r2->method, "DELETE");
ok($r2->uri, "http:");
ok($r2->protocol, "HTTP/1.1");
ok($r2->header("Accept-Encoding"), $req->header("Accept-Encoding"));

my $raw_request = <<'END';
GET / HTTP/1.1
Host: example.com
END
$req = HTTP::Request->parse($raw_request);
ok($req->method, 'GET');
ok($req->uri, 'http://example.com/');
ok($req->protocol, 'HTTP/1.1');
my $headers = $req->headers;
ok($headers->header('Host'), 'example.com');

my $r2_string = $req->as_string;
ok($r2_string, $raw_request."\n");
