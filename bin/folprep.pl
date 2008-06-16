#!/usr/bin/perl
#
# Anime recording system foltia
# http://www.dcc-jpl.com/soft/foltia/
#
#folprep.pl
#
#atから呼ばれて、目的番組がずれていないか確認します
#新しい放映時刻が15分以上先なら再度folprepのキューを入れます
#放映時刻が15分以内なら放映時刻に録画キューを入れます
#
#引数:PID
#
# DCC-JPL Japan/foltia project
#
#
use strict;
use warnings;
use Carp;
use Getopt::Long;
use Foltia;


GetOptions('-p=s' => \my $pid)
#引き数なし出実行されたら、終了
$pid or die "Usage: folprep.pl <PID>\n";

#PID探し

#キュー再投入
Foltia::Util::writelog("folprep addpidatq $pid");
my $f = new Foltia;
$f->db->addpidatq($pid);


