# https://rt.cpan.org/Public/Bug/Display.html?id=52572

use strict;
use warnings;

use Test::More;
plan tests => 10;

use HTTP::Headers    qw( );
use HTTP::Response   qw( );

# Create a nasty bzip2 stream:
my $size = 16 * 1024 * 1024;
my $stream = "\0" x $size;

# Compress that stream three times:
my $compressed = $stream;
for( 1..3 ) {
    require IO::Compress::Bzip2;
    my $last = $compressed;
    IO::Compress::Bzip2::bzip2(\$last, \$compressed)
        or die "Can't bzip2 content: $IO::Compress::Bzip2::Bzip2Error";
    #diag sprintf "Encoded size %d bytes after round %d", length $compressed, $_;
};

my $body = $compressed;

my $headers = HTTP::Headers->new(
    Content_Type => "application/xml",
    Content_Encoding => 'bzip2,bzip2,bzip2', # say my name three times
);
my $response = HTTP::Response->new(200, "OK", $headers, $body);

my $len = length $response->decoded_content( raise_error => 1 );
is($len, 16 * 1024 * 1024, "Self-test: The decoded content length is 16M as expected" );

# Manual decompression check
my $output = $compressed;
for( 1..3 ) {
    my $last = $output;
    require Compress::Raw::Bzip2;
    my ($i, $status) = Compress::Raw::Bunzip2->new(
        1, # appendInput
        0, # consumeInput
        0, # small
        1,
    );
    $output = "\0" x (1024*1024);
    # Will modify $last, but we made a copy above
    my $res = $i->bzinflate( \$last, \$output );
};
is length $output, 1024*1024, "We manually recreate the limited original stream";

$headers = HTTP::Headers->new(
    Content_Type => "application/xml",
    Content_Encoding => 'bzip2,bzip2,bzip2', # say my name three times
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
is $lives, undef, "We die when trying to decode something larger than our limit of 512k";

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
is $lives, undef, "We die when trying to decode something larger than our limit of 512k";

=head1 SEE ALSO

L<https://security.stackexchange.com/questions/51071/zlib-deflate-decompression-bomb>

L<http://www.aerasec.de/security/advisories/decompression-bomb-vulnerability.html>

=cut