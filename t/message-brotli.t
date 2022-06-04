#! perl -w

use strict;
use warnings;

use Test::More;
use Test::Needs 'IO::Compress::Brotli', 'IO::Uncompress::Brotli';

require HTTP::Message;

subtest "decoding" => sub {

    my $m = HTTP::Message->new(
        [
            "Content-Type"     => "text/plain",
            "Content-Encoding" => "br, base64",
        ],
        "CwaASGVsbG8gd29ybGQhCgM=\n"
    );
    is( $m->decoded_content, "Hello world!\n", "decoded_content() works" );
    ok( $m->decode, "decode() works" );
    is( $m->content, "Hello world!\n", "... and content() is correct" );
};

subtest "encoding" => sub {
    my $m = HTTP::Message->new(
        [
            "Content-Type" => "text/plain",
        ],
        "Hello world!"
    );
    ok( $m->encode("br"), "set encoding to 'br" );
    is( $m->header("Content-Encoding"),
        "br", "... and Content-Encoding is set" );
    isnt( $m->content, "Hello world!", "... and the content has changed" );
    is( $m->decoded_content, "Hello world!", "decoded_content() works" );
    ok( $m->decode, "decode() works" );
    is( $m->content, "Hello world!", "... and content() is correct" );
};

done_testing;
