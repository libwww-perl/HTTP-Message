use strict;
use warnings;

use Test::More;
BEGIN {
    plan skip_all => 'these tests are for authors only!'
        unless -d '.git' || $ENV{AUTHOR_TESTING};
}

eval { require Test::DistManifest; };    ## no critic (ErrorHandling::RequireCheckingReturnValueOfEval)
plan skip_all => 'Test::DistManifest required' if $@;

manifest_ok();
