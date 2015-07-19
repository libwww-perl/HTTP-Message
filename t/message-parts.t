use strict;
use warnings;

use Test::More;
plan tests => 47;

use HTTP::Message;
use HTTP::Request::Common qw(POST);

my $m = HTTP::Message->new;

is(ref($m->headers), "HTTP::Headers");
is($m->headers_as_string, "");
is($m->content, "");
is(j($m->parts), "");
is($m->as_string, "\n");

my $m_clone = $m->clone;
$m->push_header("Foo", 1);
$m->add_content("foo");

is($m_clone->as_string, "\n");
is($m->headers_as_string, "Foo: 1\n");
is($m->header("Foo"), 1);
is($m->as_string, "Foo: 1\n\nfoo\n");
is($m->as_string("\r\n"), "Foo: 1\r\n\r\nfoo");
is(j($m->parts), "");

$m->content_type("message/foo");
$m->content(<<EOT);
H1: 1
H2: 2
  3
H3:  abc

FooBar
EOT

my @parts = $m->parts;
is(@parts, 1);
my $m2 = $parts[0];
is(ref($m2), "HTTP::Message");

is($m2->header("h1"), 1);
is($m2->header("h2"), "2\n  3");
is($m2->header("h3"), " abc");
is($m2->content, "FooBar\n");
is($m2->as_string, $m->content);
is(j($m2->parts), "");

$m = POST("http://www.example.com",
	  Content_Type => 'form-data',
	  Content => [ foo => 1, bar => 2 ]);
is($m->content_type, "multipart/form-data");
@parts = $m->parts;
is(@parts, 2);
is($parts[0]->header("Content-Disposition"), 'form-data; name="foo"');
is($parts[0]->content, 1);
is($parts[1]->header("Content-Disposition"), 'form-data; name="bar"');
is($parts[1]->content, 2);

$m = HTTP::Message->new;
$m->content_type("message/http");
$m->content(<<EOT);
GET / HTTP/1.0
Host: example.com

How is this?
EOT

@parts = $m->parts;
is(@parts, 1);
is($parts[0]->method, "GET");
is($parts[0]->uri, "/");
is($parts[0]->protocol, "HTTP/1.0");
is($parts[0]->header("Host"), "example.com");
is($parts[0]->content, "How is this?\n");

$m = HTTP::Message->new;
$m->content_type("message/http");
$m->content(<<EOT);
HTTP/1.1 200 is
Content-Type : text/html

<H1>Hello world!</H1>
EOT

@parts = $m->parts;
is(@parts, 1);
is($parts[0]->code, 200);
is($parts[0]->message, "is");
is($parts[0]->protocol, "HTTP/1.1");
is($parts[0]->content_type, "text/html");
is($parts[0]->content, "<H1>Hello world!</H1>\n");

$m->parts(HTTP::Request->new("GET", "http://www.example.com"));
is($m->as_string, "Content-Type: message/http\n\nGET http://www.example.com\r\n\r\n");

$m = HTTP::Request->new("PUT", "http://www.example.com");
$m->parts(HTTP::Message->new([Foo => 1], "abc\n"), HTTP::Message->new([Bar => 2], "def"));
is($m->as_string, <<EOT);
PUT http://www.example.com
Content-Type: multipart/mixed; boundary=xYzZY

--xYzZY\r
Foo: 1\r
\r
abc
\r
--xYzZY\r
Bar: 2\r
\r
def\r
--xYzZY--\r
EOT

$m->content(<<EOT);
--xYzZY
Content-Length: 4

abcd
--xYzZY--
EOT

@parts = $m->parts;
is(@parts, 1);
is($parts[0]->content_length, 4);
is($parts[0]->content, "abcd");

$m->content("

--xYzZY
Content-Length: 4

efgh
--xYzZY
Content-Length: 3

ijk
--xYzZY--");

@parts = $m->parts;
is(@parts, 2);
is($parts[0]->content_length, 4);
is($parts[0]->content, "efgh");
is($parts[1]->content_length, 3);
is($parts[1]->content, "ijk");

sub j { join(":", @_) }
