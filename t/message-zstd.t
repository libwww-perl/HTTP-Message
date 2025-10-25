#! perl

use strict;
use warnings;

use English qw( -no_match_vars );

use Test::More;
use Test::Needs 'IO::Compress::Zstd';
use Path::Tiny qw( path );

require MIME::Base64;
require HTTP::Message;

my $files = path($PROGRAM_NAME)->parent->child('files');
my $lorem_ipsum_clear    = $files->child('lorem_ipsum.txt')->slurp_utf8;
my $lorem_ipsum_zstd_b64 = $files->child('lorem_ipsum.txt-zst-b64')->slurp_raw;
my $lorem_ipsum_zstd = MIME::Base64::decode($lorem_ipsum_zstd_b64);

subtest "no decoding" => sub {

    my $m = HTTP::Message->new(
        [
            "Content-Type"     => "text/plain",
            "Content-Encoding" => "",
        ],
        $lorem_ipsum_clear
    );
    is( $m->decoded_content, $lorem_ipsum_clear, "decoded_content() works, is same as content" );
    ok( $m->decode, "decode() works" );
    is( $m->content, $lorem_ipsum_clear, "... and content() is correct" );
};

subtest "decoding zstd" => sub {

    my $m = HTTP::Message->new(
        [
            "Content-Type"     => "text/plain",
            "Content-Encoding" => "zstd",
        ],
        $lorem_ipsum_zstd
    );
    is( $m->decoded_content, $lorem_ipsum_clear, "decoded_content() works" );
    ok( $m->decode, "decode() works" );
    is( $m->content, $lorem_ipsum_clear, "... and content() is correct" );
};

subtest "decoding zstd in base64" => sub {

    my $m = HTTP::Message->new(
        [
            "Content-Type"     => "text/plain",
            "Content-Encoding" => "zstd, base64",
        ],
        $lorem_ipsum_zstd_b64
    );
    is( $m->decoded_content, $lorem_ipsum_clear, "decoded_content() works" );
    ok( $m->decode, "decode() works" );
    is( $m->content, $lorem_ipsum_clear, "... and content() is correct" );
};

subtest "encoding to zstd" => sub {
    my $m = HTTP::Message->new(
        [
            "Content-Type" => "text/plain",
        ],
        $lorem_ipsum_clear
    );
    is( $m->content, $lorem_ipsum_clear, "the content is the original" );
    ok( $m->encode("zstd"), "set encoding to 'zstd'" );
    is( $m->header("Content-Encoding"),
        "zstd", "... and Content-Encoding is set" );
    isnt( $m->content, $lorem_ipsum_clear, "... and the content has changed" );
    is( $m->content, $lorem_ipsum_zstd, "... and the content is correct" );
    is( $m->decoded_content, $lorem_ipsum_clear, "decoded_content() works" );
    ok( $m->decode, "decode() works" );
    is( $m->content, $lorem_ipsum_clear, "... and content() is correct" );
};

subtest "encoding to zstd in base64" => sub {
    my $m = HTTP::Message->new(
        [
            "Content-Type" => "text/plain",
        ],
        $lorem_ipsum_clear
    );
    is( $m->content, $lorem_ipsum_clear, "the content is the original" );
    ok( $m->encode("zstd", "base64"), "set encoding to 'zstd' in 'base64'" );
    is( $m->header("Content-Encoding"),
        "zstd, base64", "... and Content-Encoding is set" );
    isnt( $m->content, $lorem_ipsum_clear, "... and the content has changed" );
    is( $m->content, $lorem_ipsum_zstd_b64, "... and the content is correct" );
    is( $m->decoded_content, $lorem_ipsum_clear, "decoded_content() works" );
    ok( $m->decode, "decode() works" );
    is( $m->content, $lorem_ipsum_clear, "... and content() is correct" );
};

done_testing;
