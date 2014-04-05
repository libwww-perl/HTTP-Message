#!perl -w

use Test;
plan tests => 6;

use HTTP::Status;

my %StatusCode = HTTP::Status->status_codes;

ok(!$StatusCode{0});

for $status (qw/100 200 300 400 500/) {
    ok($StatusCode{$status});
}
