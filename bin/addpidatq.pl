#!/usr/bin/perl
#
# Anime recording system foltia
# http://www.dcc-jpl.com/soft/foltia/
#
#addpidatq.pl
#
#PID受け取りatqに入れる。folprep.plからキュー再入力のために使われる
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
$pid or die "Usage: addpidatq.pl -p <PID>\n";

my $f = new Foltia;
$f->db->addpidatq($pid);
