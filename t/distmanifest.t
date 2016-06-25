use strict;
use warnings;

use Test::More;
BEGIN {
    plan skip_all => 'these tests are for authors only!'
        unless -d '.git' || $ENV{AUTHOR_TESTING};

    plan skip_all => 'these tests require Test::DistManifest'
      unless eval{ require Test::DistManifest; };
}

Test::DistManifest::manifest_ok();
