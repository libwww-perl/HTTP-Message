#!perl -w

use Test;
plan tests => 7;

use HTTP::Status;

my $StatusCode = HTTP::Status->all_status;

ok(ref($StatusCode) eq 'HASH');

ok(!$StatusCode->{0});

for $status (qw/100 200 300 400 500/) {
    ok($StatusCode->{$status});
}
