#!/usr/bin/perl
#
# Anime recording system foltia
# http://www.dcc-jpl.com/soft/foltia/
#
#
#deletemovie.pl
#
#ファイル名を受け取り、削除処理をする
#とりあえずは./mita/へ移動
#
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
GetOptions('-f=s' => \my $file);

#引き数なし出実行されたら、終了
$file or die "Usage: deletemovie.pl <FILENAME>\n";

my $f = new Foltia;
$f->video->deletemovie($file);
