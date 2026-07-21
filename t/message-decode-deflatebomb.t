# CVE-2026-65060: max_body_size was not enforced on the "deflate" path,
# so a decompression bomb labelled Content-Encoding: deflate bypassed the
# cap that gzip/bzip2/brotli honour.

use strict;
use warnings;

use Test::More;

use HTTP::Headers    qw( );
use HTTP::Response   qw( );

use Test::Needs {
    'IO::Compress::Deflate'    => 0,
    'IO::Compress::RawDeflate' => 0,
};

require IO::Compress::Deflate;
require IO::Compress::RawDeflate;

my $size   = 1024 * 1024;
my $cap    = 64 * 1024;
my $stream = "\0" x $size;

IO::Compress::Deflate::deflate( \$stream, \my $bomb, Level => 9 )
    or die "Can't deflate content: $IO::Compress::Deflate::DeflateError";

IO::Compress::RawDeflate::rawdeflate( \$stream, \my $raw_bomb, Level => 9 )
    or die
    "Can't rawdeflate content: $IO::Compress::RawDeflate::RawDeflateError";

sub response_for {
    my ( $body, $max_body_size ) = @_;
    my $headers = HTTP::Headers->new(
        Content_Type     => 'application/octet-stream',
        Content_Encoding => 'deflate',
    );
    my $response = HTTP::Response->new( 200, 'OK', $headers, $body );
    $response->max_body_size($max_body_size);
    return $response;
}

# Self-test: without a limit the bomb decodes in full.
{
    my $content = response_for( $bomb, undef )->decoded_content;
    is( length $content, $size,
        'Self-test: zlib-deflate bomb decodes in full' );

    $content = response_for( $raw_bomb, undef )->decoded_content;
    is( length $content, $size,
        'Self-test: raw-deflate bomb decodes in full' );
}

# The cap must be enforced, exactly as it is for gzip.
{
    my $response = response_for( $bomb, $cap );
    my $content;
    my $lives = eval {
        $content = $response->decoded_content( raise_error => 1 );
        1;
    };
    is( $lives, undef,
        'We die decoding a zlib-deflate body larger than max_body_size' );
    like( $@, qr/larger than $cap octets/,
        '... and the error names the limit' );
}

{
    my $response = response_for( $raw_bomb, $cap );
    my $content;
    my $lives = eval {
        $content = $response->decoded_content( raise_error => 1 );
        1;
    };
    is( $lives, undef,
        'We die decoding a raw-deflate body larger than max_body_size' );
    like( $@, qr/larger than $cap octets/,
        '... and the error names the limit' );
}

# The per-call parameter works too.
{
    my $response = response_for( $bomb, undef );
    my $lives    = eval {
        $response->decoded_content(
            raise_error   => 1,
            max_body_size => $cap,
        );
        1;
    };
    is( $lives, undef, 'The max_body_size parameter caps a deflate body' );
}

# Without raise_error we get undef rather than a bomb.
{
    my $response = response_for( $bomb, $cap );
    ok( !defined $response->decoded_content( raise_error => 0 ),
        'Without raise_error an over-large deflate body decodes to undef' );
}

# Content that fits under the cap still decodes correctly.
{
    my $body = 'x' x 1000;

    IO::Compress::Deflate::deflate( \$body, \my $small )
        or die "Can't deflate content: $IO::Compress::Deflate::DeflateError";
    my $response = response_for( $small, $cap );
    is( $response->decoded_content( raise_error => 1 ), $body,
        'A zlib-deflate body under the cap decodes correctly' );

    IO::Compress::RawDeflate::rawdeflate( \$body, \my $small_raw )
        or die
        "Can't rawdeflate content: $IO::Compress::RawDeflate::RawDeflateError";
    $response = response_for( $small_raw, $cap );
    is( $response->decoded_content( raise_error => 1 ), $body,
        'A raw-deflate body under the cap decodes correctly' );
}

# A negative limit is a caller error. It has to fail loudly: silently
# handing back empty content would look like a successful decode.
{
    for my $limit ( -1, -1000 ) {
        my $response = response_for( $bomb, $limit );
        my $lives    = eval {
            $response->decoded_content( raise_error => 1 );
            1;
        };
        is( $lives, undef, "A max_body_size of $limit is rejected" );
    }
}

# Content exactly at the cap is not rejected.
{
    my $body = 'x' x 1024;
    IO::Compress::Deflate::deflate( \$body, \my $small )
        or die "Can't deflate content: $IO::Compress::Deflate::DeflateError";
    my $response = response_for( $small, 1024 );
    is( $response->decoded_content( raise_error => 1 ), $body,
        'A deflate body exactly at the cap decodes correctly' );
}

# Content that begins as a deflate stream but stops in the middle of one
# cannot be decoded either way round, with or without a limit in force. The
# decoders report that differently, so check both paths through the error
# handling.
{
    my $body = 'x' x 10_000;
    IO::Compress::RawDeflate::rawdeflate( \$body, \my $truncated )
        or die
        "Can't rawdeflate content: $IO::Compress::RawDeflate::RawDeflateError";
    substr( $truncated, -5 ) = q{};

    for my $limit ( undef, $cap ) {
        my $with     = defined $limit ? 'with' : 'without';
        my $response = response_for( $truncated, $limit );
        my $lives    = eval {
            $response->decoded_content( raise_error => 1 );
            1;
        };
        is( $lives, undef,
            "A truncated deflate stream is refused $with a limit" );
        like(
            $response->header('Client-Warning'),
            qr/Could not raw inflate content/,
            '... and the raw-deflate failure lands in Client-Warning'
        );
    }
}

# The raw-deflate fallback passes undecodable content through untouched
# (IO::Uncompress::RawInflate's Transparent mode). Keep that behaviour: such
# content is not amplified, so the cap has nothing to protect against.
{
    my $body     = 'this is not deflated at all';
    my $response = response_for( $body, $cap );
    is( $response->decoded_content( raise_error => 1 ), $body,
        'Undecodable content is passed through unchanged' );
}

done_testing();
