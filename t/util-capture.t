use strict;
use warnings;

use Foltia::Util;

use Test::Base;
filters { input => 'chomp', expected => 'yaml' };
plan tests => 1 * blocks;

run {
    my $block = shift;
    my @filename_capture = [Foltia::Util::capture_image_filename_parse($block->input)];
    is_deeply @filename_capture, $block->expected, $block->name;
}

__END__
=== 0--20080615-1324-99.m2p
--- input
0--20080615-1324-99.m2p
--- expected
- '0'
- ''
- '20080615'
- '1324'

=== 10-23-20080115-2468-22.m2p
--- input
10-23-20080115-2468-22.m2p
--- expected
- '10'
- '23'
- '20080115'
- '2468'
