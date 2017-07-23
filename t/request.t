# Test extra HTTP::Request methods.  Basic operation is tested in the
# message.t test suite.

use strict;
use warnings;

use Test::More;
plan tests => 35;

use HTTP::Request;
use Try::Tiny qw( catch try );

my $req = HTTP::Request->new( GET => "http://www.example.com" );
$req->accept_decodable;

is( $req->method, "GET" );
is( $req->uri,    "http://www.example.com" );
like( $req->header("Accept-Encoding"), qr/\bgzip\b/ )
    ;    # assuming IO::Uncompress::Gunzip is there

$req->dump( prefix => "# " );

is( $req->method("DELETE"), "GET" );
is( $req->method,           "DELETE" );

is( $req->uri("http:"), "http://www.example.com" );
is( $req->uri,          "http:" );

$req->protocol("HTTP/1.1");

my $r2 = HTTP::Request->parse( $req->as_string );
is( $r2->method,                    "DELETE" );
is( $r2->uri,                       "http:" );
is( $r2->protocol,                  "HTTP/1.1" );
is( $r2->header("Accept-Encoding"), $req->header("Accept-Encoding") );

# Test objects which are accepted as URI-like
{
    package Foo::URI;

    use strict;
    use warnings;

    sub new { return bless {}, shift; }
    sub clone  { return shift }
    sub scheme { }

    1;

    package Foo::URI::WithCanonical;

    sub new { return bless {}, shift; }
    sub clone     { return shift }
    sub scheme    { }
    sub canonical { }

    1;

    package Foo::URI::WithoutScheme;

    sub new { return bless {}, shift; }
    sub clone     { return shift }

    1;

    package main;

    ok( Foo::URI->new->can('scheme'), 'Object can scheme()' );
    ok(
        !do {
            try {
                HTTP::Request->new( GET => Foo::URI->new );
                return 1;
            }
            catch { return 0 };
        },
        'Object without canonical method triggers an exception'
    );

    ok(
        Foo::URI::WithCanonical->new->can('canonical'),
        'Object can canonical()'
    );

    ok(
        do {
            try {
                HTTP::Request->new( GET => Foo::URI::WithCanonical->new );
                return 1;
            }
            catch { return 0 };
        },
        'Object with canonical method does not trigger an exception'
    );

    ok( !Foo::URI::WithoutScheme->new->can('scheme'), 'Object cannot scheme()' );
    ok(
        !do {
            try {
                HTTP::Request->new( GET => Foo::URI::WithoutScheme->new );
                return 1;
            }
            catch { return 0 };
        },
        'Object without scheme method triggers an exception'
    );
}

eval { $req->uri ({ foo => 'bar'}); };
like($@, qr/A URI can't be a HASH reference/);
eval { $req->uri (['foo']); };
like($@, qr/A URI can't be a ARRAY reference/);

$req = HTTP::Request->new;
is($req->as_string, "- -\n\n");
is($req->dump, <<EOT);
- -

(no content)
EOT
$req->protocol("HTTP/1.1");
is($req->dump, <<EOT);
- - HTTP/1.1

(no content)
EOT

{
	my @warn;
	local $SIG{__WARN__} = sub { push @warn, @_ };
	local $^W = 0;
	$r2 = HTTP::Request->parse( undef );
	is($#warn, -1);
	local $^W = 1;
	$r2 = HTTP::Request->parse( undef );
	is($#warn, 0);
	like($warn[0], qr/Undefined argument to parse\(\)/);
}
is( $r2->method,                    undef );
is( $r2->uri,                       undef );
is( $r2->protocol,                  undef );
is( $r2->header("Accept-Encoding"), $req->header("Accept-Encoding") );

$r2 = HTTP::Request->parse('methonly');
is( $r2->method,   'methonly' );
is( $r2->uri,      undef );
is( $r2->protocol, undef );

$r2 = HTTP::Request->parse('methonly http://www.example.com/');
is( $r2->method,   'methonly' );
is( $r2->uri,      'http://www.example.com/' );
is( $r2->protocol, undef );
