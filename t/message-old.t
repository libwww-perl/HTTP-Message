# This is the old message.t test.  It is not maintained any more,
# but kept around in case it happens to catch any mistakes.  Please
# add new tests to message.t instead.

use strict;
use warnings;

use Test::More;

plan tests => 20;

require HTTP::Request;
require HTTP::Response;

require Time::Local if $^O eq "MacOS";
my $offset = ($^O eq "MacOS") ? Time::Local::timegm(0,0,0,1,0,1970) : 0;

my $req = HTTP::Request->new(GET => "http://www.sn.no/");
$req->header(
	"if-modified-since" => "Thu, 03 Feb 1994 00:00:00 GMT",
	"mime-version"      => "1.0");

ok($req->as_string =~ /^GET/m);
is($req->header("MIME-Version"), "1.0");
is($req->if_modified_since, ((760233600 + $offset) || 0));

$req->content("gisle");
$req->add_content(" aas");
$req->add_content(\ " old interface is depreciated");
${$req->content_ref} =~ s/\s+is\s+depreciated//;

is($req->content, "gisle aas old interface");

my $time = time;
$req->date($time);
my $timestr = gmtime($time);
my($month) = ($timestr =~ /^\S+\s+(\S+)/);  # extract month;
#print "These should represent the same time:\n\t", $req->header('Date'), "\n\t$timestr\n";
like($req->header('Date'), qr/\Q$month/);

$req->authorization_basic("gisle", "passwd");
is($req->header("Authorization"), "Basic Z2lzbGU6cGFzc3dk");

my($user, $pass) = $req->authorization_basic;
is($user, "gisle");
is($pass, "passwd");

# Check the response
my $res = HTTP::Response->new(200, "This message");
ok($res->is_success);

my $html = $res->error_as_HTML;
ok($html =~ /<head>/i && $html =~ /This message/);

$res->content_type("text/html;version=3.0");
$res->content("<html>...</html>\n");

my $res2 = $res->clone;
is($res2->code, 200);
is($res2->header("cOntent-TYPE"), "text/html;version=3.0");
like($res2->content, qr/>\.\.\.</);

# Check the base method:
$res = HTTP::Response->new(200, "This message");
is($res->base, undef);
$res->request($req);
$res->content_type("image/gif");

is($res->base, "http://www.sn.no/");
$res->header('Base', 'http://www.sn.no/xxx/');
is($res->base, "http://www.sn.no/xxx/");

# Check the AUTLOAD delegate method with regular expressions
"This string contains text/html" =~ /(\w+\/\w+)/;
$res->content_type($1);
is($res->content_type, "text/html");

# Check what happens when passed a new URI object
require URI;
$req = HTTP::Request->new(GET => URI->new("http://localhost"));
is($req->uri, "http://localhost");

$req = HTTP::Request->new(GET => "http://www.example.com",
	                  [ Foo => 1, bar => 2 ], "FooBar\n");
is($req->as_string, <<EOT);
GET http://www.example.com
Bar: 2
Foo: 1

FooBar
EOT

$req->clear;
is($req->as_string,  <<EOT);
GET http://www.example.com

EOT
