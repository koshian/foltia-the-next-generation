#!/usr/bin/perl
#
# Anime recording system foltia
# http://www.dcc-jpl.com/soft/foltia/
#
#usage ;mklocalizeddir.pl [TID]
# Mac OS X Localizedフォーマットに準拠した構造の録画ディレクトリを作る。
# 参考:[Mac OS X 10.2のローカライズ機能] http://msyk.net/macos/jaguar-localize/
#
# DCC-JPL Japan/foltia project
#
#
use strict;
use warnings;
use Carp;
use Getopt::Long;
use Foltia;


GetOptions('-t=s' => \my $tid)

#引き数がアルか?	#引き数なし出実行されたら、終了
$tid or die "Usage: mklocalizeddir.pl [TID]\n";

my $f = new Foltia;
$f->video->mklocalizeddir($tid);
