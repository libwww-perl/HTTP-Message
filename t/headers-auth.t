use strict;
use warnings;

use Test::More;

plan tests => 9;

use HTTP::Response;
use HTTP::Headers::Auth;

my $res = HTTP::Response->new(401);
$res->push_header(WWW_Authenticate => qq(Foo realm="WallyWorld", foo=bar, Bar realm="WallyWorld2"));
$res->push_header(WWW_Authenticate => qq(Basic Realm="WallyWorld", foo=bar, bar=baz));

note $res->as_string;

my %auth = $res->www_authenticate;

is(keys(%auth), 3);

is($auth{basic}{realm}, "WallyWorld");
is($auth{bar}{realm}, "WallyWorld2");

$a = $res->www_authenticate;
is($a, 'Foo realm="WallyWorld", foo=bar, Bar realm="WallyWorld2", Basic Realm="WallyWorld", foo=bar, bar=baz');

$res->www_authenticate("Basic realm=foo1");
note $res->as_string;

$res->www_authenticate(Basic => {realm => "foo2"});
print $res->as_string;

$res->www_authenticate(Basic => [realm => "foo3", foo=>33],
                       Digest => {nonce=>"bar", foo=>'foo'});
note $res->as_string;

my $string = $res->as_string;

like($string, qr/WWW-Authenticate: Basic realm="foo3", foo=33/);
like($string, qr/WWW-Authenticate: Digest (nonce=bar, foo=foo|foo=foo, nonce=bar)/);

$res = HTTP::Response->new(401);
my @auth = $res->proxy_authenticate('foo');
is_deeply(\@auth, []);
@auth = $res->proxy_authenticate('foo', 'bar');
is_deeply(\@auth, ['foo', {}]);
@auth = $res->proxy_authenticate('foo', {'bar' => '_'});
is_deeply(\@auth, ['foo', {}, 'bar', {}]);
