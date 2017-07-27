use strict;
use warnings;

use Test::More;
plan tests => 64;

use HTTP::Request::Common;

my $r = GET 'http://www.sn.no/';
note $r->as_string;

is($r->method, "GET");
is($r->uri, "http://www.sn.no/");

$r = HEAD "http://www.sn.no/",
     If_Match => 'abc',
     From => 'aas@sn.no';
note $r->as_string;

is($r->method, "HEAD");
ok($r->uri->eq("http://www.sn.no"));

is($r->header('If-Match'), "abc");
is($r->header("from"), "aas\@sn.no");

$r = HEAD "http://www.sn.no/",
	Content => 'foo';
is($r->content, 'foo');

$r = HEAD "http://www.sn.no/",
	Content => 'foo',
	'Content-Length' => 50;
is($r->content, 'foo');
is($r->content_length, 50);

$r = PUT "http://www.sn.no",
     Content => 'foo';
note $r->as_string, "\n";

is($r->method, "PUT");
is($r->uri->host, "www.sn.no");

ok(!defined($r->header("Content")));

is(${$r->content_ref}, "foo");
is($r->content, "foo");
is($r->content_length, 3);

$r = PUT "http://www.sn.no",
     { foo => "bar" };
is($r->content, "foo=bar");

$r = PATCH "http://www.sn.no",
     { foo => "bar" };
is($r->content, "foo=bar");

#--- Test POST requests ---

$r = POST "http://www.sn.no", [foo => 'bar;baz',
                               baz => [qw(a b c)],
                               foo => 'zoo=&',
                               "space " => " + ",
			       "nl" => "a\nb\r\nc\n",
                              ],
                              bar => 'foo';
note $r->as_string, "\n";

is($r->method, "POST");
is($r->content_type, "application/x-www-form-urlencoded");
is($r->content_length, 83);
is($r->header("bar"), "foo");
is($r->content, "foo=bar%3Bbaz&baz=a&baz=b&baz=c&foo=zoo%3D%26&space+=+%2B+&nl=a%0D%0Ab%0D%0Ac%0D%0A");

$r = POST "http://example.com";
is($r->content_length, 0);
is($r->content, "");

$r = POST "http://example.com", [];
is($r->content_length, 0);
is($r->content, "");

$r = POST "mailto:gisle\@aas.no",
     Subject => "Heisan",
     Content_Type => "text/plain",
     Content => "Howdy\n";
#note $r->as_string;

is($r->method, "POST");
is($r->header("Subject"), "Heisan");
is($r->content, "Howdy\n");
is($r->content_type, "text/plain");

{
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    $r = POST 'http://unf.ug/', [];
    is( "@warnings", '', 'empty POST' );
}

#
# POST for File upload
#
my $file = "test-$$";
open(FILE, ">$file") or die "Can't create $file: $!";
print FILE "foo\nbar\nbaz\n";
close(FILE);

$r = POST 'http://www.perl.org/survey.cgi',
       Content_Type => 'form-data',
       Content      => [ name  => 'Gisle Aas',
                         email => 'gisle@aas.no',
                         gender => 'm',
                         born   => '1964',
                         file   => [$file],
                       ];
#note $r->as_string;

unlink($file) or warn "Can't unlink $file: $!";

is($r->method, "POST");
is($r->uri->path, "/survey.cgi");
is($r->content_type, "multipart/form-data");
ok($r->header('Content_type') =~ /boundary="?([^"]+)"?/);
my $boundary = $1;

my $c = $r->content;
$c =~ s/\r//g;
my @c = split(/--\Q$boundary/, $c);
note "$c[5]\n";

is(@c, 7);
like($c[6], qr/^--\n/);  # 5 parts + header & trailer

ok($c[2] =~ /^Content-Disposition:\s*form-data;\s*name="email"/m);
ok($c[2] =~ /^gisle\@aas.no$/m);

ok($c[5] =~ /^Content-Disposition:\s*form-data;\s*name="file";\s*filename="$file"/m);
ok($c[5] =~ /^Content-Type:\s*text\/plain$/m);
ok($c[5] =~ /^foo\nbar\nbaz/m);

$r = POST 'http://www.perl.org/survey.cgi',
      [ file => [ undef, "xxy\"", Content_type => "text/html", Content => "<h1>Hello, world!</h1>" ]],
      Content_type => 'multipart/form-data';
#note $r->as_string;

ok($r->content =~ /^--\S+\015\012Content-Disposition:\s*form-data;\s*name="file";\s*filename="xxy\\"/m);
ok($r->content =~ /^Content-Type: text\/html/m);
ok($r->content =~ /^<h1>Hello, world/m);

$r = POST 'http://www.perl.org/survey.cgi',
      Content_type => 'multipart/form-data',
      Content => [ file => [ undef, undef, Content => "foo"]];
#note $r->as_string;

unlike($r->content, qr/filename=/);


# The POST routine can now also take a hash reference.
my %hash = (foo => 42, bar => 24);
$r = POST 'http://www.perl.org/survey.cgi', \%hash;
#note $r->as_string, "\n";
like($r->content, qr/foo=42/);
like($r->content, qr/bar=24/);
is($r->content_type, "application/x-www-form-urlencoded");
is($r->content_length, 13);

 
#
# POST for File upload
#
use HTTP::Request::Common qw($DYNAMIC_FILE_UPLOAD);

$file = "test-$$";
open(FILE, ">$file") or die "Can't create $file: $!";
for (1..1000) {
   print FILE "a" .. "z";
}
close(FILE);

$DYNAMIC_FILE_UPLOAD++;
$r = POST 'http://www.perl.org/survey.cgi',
       Content_Type => 'form-data',
       Content      => [ name  => 'Gisle Aas',
                         email => 'gisle@aas.no',
                         gender => 'm',
                         born   => '1964',
                         file   => [$file],
                       ];
#note $r->as_string, "\n";

is($r->method, "POST");
is($r->uri->path, "/survey.cgi");
is($r->content_type, "multipart/form-data");
ok($r->header('Content_type') =~ qr/boundary="?([^"]+)"?/);
$boundary = $1;
is(ref($r->content), "CODE");

cmp_ok(length($boundary), '>', 10);

my $code = $r->content;
my $chunk;
my @chunks;
while (defined($chunk = &$code) && length $chunk) {
   push(@chunks, $chunk);
}

unlink($file) or warn "Can't unlink $file: $!";

$_ = join("", @chunks);

#note int(@chunks), " chunks, total size is ", length($_), " bytes\n";

# should be close to expected size and number of chunks
cmp_ok(abs(@chunks - 15), '<', 3);
cmp_ok(abs(length($_) - 26589), '<', 20);

$r = POST 'http://www.example.com';
is($r->as_string, <<EOT);
POST http://www.example.com
Content-Length: 0
Content-Type: application/x-www-form-urlencoded

EOT

$r = POST 'http://www.example.com', Content_Type => 'form-data', Content => [];
is($r->as_string, <<EOT);
POST http://www.example.com
Content-Length: 0
Content-Type: multipart/form-data; boundary=none

EOT

$r = POST 'http://www.example.com', Content_Type => 'form-data';
#note $r->as_string;
is($r->as_string, <<EOT);
POST http://www.example.com
Content-Length: 0
Content-Type: multipart/form-data

EOT

$r = HTTP::Request::Common::DELETE 'http://www.example.com';
is($r->method, "DELETE");

$r = HTTP::Request::Common::PUT 'http://www.example.com',
    'Content-Type' => 'application/octet-steam',
    'Content' => 'foobarbaz',
    'Content-Length' => 12;   # a slight lie
is($r->header('Content-Length'), 9);

$r = HTTP::Request::Common::PATCH 'http://www.example.com',
    'Content-Type' => 'application/octet-steam',
    'Content' => 'foobarbaz',
    'Content-Length' => 12;   # a slight lie
is($r->header('Content-Length'), 9);
