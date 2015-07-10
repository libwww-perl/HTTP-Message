use strict;
use warnings;

use Test::More 0.88;
use HTTP::Request::Common;

# I'd use Test::Warnings here, but let's respect our downstream consumers and
# not force that prereq on them
my @warnings;
$SIG{__WARN__} = sub { push @warnings, grep { length } @_ };

my $request = HTTP::Request::Common::request_type_with_data(
    'POST' => 'https://localhost/',
    'content_type' => 'multipart/form-data; boundary=----1234',
    'content' => [ a => 1, b => undef ],
);

isa_ok($request, 'HTTP::Request');
is(scalar(@warnings), 0, 'no warnings')
    or diag('got warnings: ', explain(\@warnings));

done_testing;
