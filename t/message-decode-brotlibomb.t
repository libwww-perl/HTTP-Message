# https://rt.cpan.org/Public/Bug/Display.html?id=52572

use strict;
use warnings;

use Test::More;

use HTTP::Headers    qw();
use HTTP::Response   qw();

use Test::Needs 'IO::Compress::Brotli', 'IO::Uncompress::Brotli';

plan tests => 9;

# Create a nasty brotli stream:
my $size = 16 * 1024 * 1024;
my $stream = "\0" x $size;

# Compress that stream one time (since it won't compress it twice?!):
my $compressed = $stream;
my $bro = IO::Compress::Brotli->create;

for( 1 ) {
    my $last = $compressed;
    $compressed = $bro->compress( $compressed );
    $compressed .= $bro->finish();
    note sprintf "Encoded size %d bytes after round %d", length $compressed, $_;
};

my $body = $compressed;

my $headers = HTTP::Headers->new(
    Content_Type => "application/xml",
    Content_Encoding => 'br', # only one round needed for Brotli
);
my $response = HTTP::Response->new(200, "OK", $headers, $body);

my $len = length $response->decoded_content;
is($len, 16 * 1024 * 1024, "Self-test: The decoded content length is 16M as expected" );

# Manual decompression check
my $output = $compressed;
for( 1 ) {
    my $unbro = IO::Uncompress::Brotli->create();
    $output = $unbro->decompress($compressed);
};

$headers = HTTP::Headers->new(
    Content_Type => "application/xml",
    Content_Encoding => 'br' # say my name, but only once
);

$HTTP::Message::MAXIMUM_BODY_SIZE = 1024 * 1024;

$response = HTTP::Response->new(200, "OK", $headers, $body);
is $response->max_body_size, 1024*1024, "The default maximum body size holds";

$response->max_body_size( 512*1024 );
is $response->max_body_size, 512*1024, "We can change the maximum body size";

my $content;
my $lives = eval {
    $content = $response->decoded_content( raise_error => 1 );
    1;
};
my $err = $@;
is $lives, undef, "We die when trying to decode something larger than our global limit of 512k"
    or diag "... using IO::Uncompress::Brotli version $IO::Uncompress::Brotli::VERSION";

$response->max_body_size(undef);
is $response->max_body_size, undef, "We can remove the maximum size restriction";
$lives = eval {
    $content = $response->decoded_content( raise_error => 0 );
    1;
};
is $lives, 1, "We don't die when trying to decode something larger than our global limit of 1M";
is length $content, 16 * 1024*1024, "We get the full content";
is $content, $stream, "We really get the full content";

# The best usage of ->decoded_content:
$lives = eval {
    $content = $response->decoded_content(
        raise_error => 1,
        max_body_size => 512 * 1024 );
    1;
};
$err = $@;
is $lives, undef, "We die when trying to decode something larger than our limit of 512k using a parameter"
    or diag "... using IO::Uncompress::Brotli version $IO::Uncompress::Brotli::VERSION";

=head1 SEE ALSO

L<https://security.stackexchange.com/questions/51071/zlib-deflate-decompression-bomb>

L<http://www.aerasec.de/security/advisories/decompression-bomb-vulnerability.html>

=cut
