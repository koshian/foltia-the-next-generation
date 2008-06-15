use strict;
use warnings;

use Foltia::Util;

use Test::Base;
filters { input => 'chomp', expected => 'chomp' };
plan tests => 1 * blocks;

run {
    my $block = shift;
    is Foltia::Util::filenameinjectioncheck($block->input), $block->expected;
}

__END__
===
--- input
0--20080615-1324-99_a;b&c|d/e.m2p
--- expected
0--20080615-1324-99_abcde.m2p

===
--- input
0--20080101-2468-11_ghik.m2p
--- expected
0--20080101-2468-11_ghik.m2p



