use strict;
use warnings;

use Test::More;

plan tests => 4;

require HTTP::Headers::ETag;

my $h = HTTP::Headers->new;

$h->etag("tag1");
is($h->etag, qq("tag1"));

$h->etag("w/tag2");
is($h->etag, qq(W/"tag2"));

$h->if_match(qq(W/"foo", bar, baz), "bar");
$h->if_none_match(333);

$h->if_range("tag3");
is($h->if_range, qq("tag3"));

my $t = time;
$h->if_range($t);
is($h->if_range, $t);

note $h->as_string;

