package Secret;

use strict;
use warnings;

use overload (
    q{""}    => 'to_string',
    fallback => 1,
);

sub new {
    my ( $class, $s ) = @_;
    return bless sub {$s}, $class;
}

sub to_string { shift->(); }

1;
