use strict;
use warnings;

use Test::More;

plan tests => 11;

require HTTP::Headers::ETag;

my $h = HTTP::Headers->new;

$h->etag("tag1");
is($h->etag, qq("tag1"));

$h->etag("w/tag2");
is($h->etag, qq(W/"tag2"));

$h->etag(" w/, weaktag");
is($h->etag, qq(W/"", "weaktag"));
my @list = $h->etag;
is_deeply(\@list, ['W/""', '"weaktag"']);

$h->etag(" w/");
is($h->etag, qq(W/""));

$h->etag(" ");
is($h->etag, "");

$h->if_match(qq(W/"foo", bar, baz), "bar");
$h->if_none_match(333);

$h->if_range("tag3");
is($h->if_range, qq("tag3"));

my $t = time;
$h->if_range($t);
is($h->if_range, $t);

note $h->as_string;

@list = $h->if_range;
is($#list, 0);
is($list[0], $t);
$h->if_range(undef);
is($h->if_range, '');
