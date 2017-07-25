use strict;
use warnings;

use Test::More;

use HTTP::Headers::Util qw(split_header_words join_header_words);

my @s_tests = (

   ["foo"                     => "foo"],
   ["foo=bar"                 => "foo=bar"],
   ["   foo   "               => "foo"],
   ["foo="                    => 'foo=""'],
   ["foo=bar bar=baz"         => "foo=bar; bar=baz"],
   ["foo=bar;bar=baz"         => "foo=bar; bar=baz"],
   ['foo bar baz'             => "foo; bar; baz"],
   ['foo="\"" bar="\\\\"'     => 'foo="\""; bar="\\\\"'],
   ['foo,,,bar'               => 'foo, bar'],
   ['foo=bar,bar=baz'         => 'foo=bar, bar=baz'],

   ['TEXT/HTML; CHARSET=ISO-8859-1' =>
    'text/html; charset=ISO-8859-1'],

   ['foo="bar"; port="80,81"; discard, bar=baz' =>
    'foo=bar; port="80,81"; discard, bar=baz'],

   ['Basic realm="\"foo\\\\bar\""' =>
    'basic; realm="\"foo\\\\bar\""'],
);

plan tests => @s_tests + 3;

for (@s_tests) {
   my($arg, $expect) = @$_;
   my @arg = ref($arg) ? @$arg : $arg;

   my $res = join_header_words(split_header_words(@arg));
   is($res, $expect);
}


note "# Extra tests\n";
# some extra tests
is(join_header_words("foo" => undef, "bar" => "baz"), "foo; bar=baz");
is(join_header_words(), "");
is(join_header_words([]), "");
