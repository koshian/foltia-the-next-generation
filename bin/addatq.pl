#!/usr/bin/perl
#
# Anime recording system foltia
# http://www.dcc-jpl.com/soft/foltia/
#
#addatq.pl
#
#TIDと局IDを受け取りatqに入れる
# addatq.pl <TID> <StationID> [DELETE]
# DELETEフラグがつくと削除のみ行う
#
# DCC-JPL Japan/foltia project
#
#

use strict;
use warnings;
use Carp;
use Getopt::Long;
use Foltia;

#引き数がアルか?
GetOptions('-t=s' => \my $tid, '-s=s' => \my $station);

#引き数なし出実行されたら、終了
($tid || $station) or die "Usage: addatq.pl -t <TID> -s <StationID> [DELETE]\n";

my $f = new Foltia;
$f->video->addatq($tid, $station);
