#!/usr/bin/perl
#usage captureimagemaker.pl  MPEG2filename
#
# Anime recording system foltia
# http://www.dcc-jpl.com/soft/foltia/
#
#
# キャプチャ画像作成モジュール
# recwrap.plから呼び出される。
#
# DCC-JPL Japan/foltia project
#

use strict;
use warnings;
use Carp;
use Getopt::Long;
use Foltia;

GetOptions('-f=s' => \my $filename);
my ($tid, $countno, $date, $time)
    = Foltia::Util::capture_image_filename_parse($filename);

#引き数なし出実行されたら、終了
$tid or die "Usage: captureimagemaker.pl  MPEG2filename\n";

if ($tid < 0) {
    my $msg = "captureimagemaker TID invalid";
    Foltia::Util::writelog($msg);
    die $msg, "\n";
}

my $f = new Foltia;

#　録画ファイルがアルかチェック
my $file = srpintf('%s/%s', $f->config->{recfolderpath}, $filename);
if (! -e $file){
    my $msg = "captureimagemaker notexist $file";
	Foltia::Util::writelog($msg);
    die $msg;
}

# 展開先ディレクトリがあるか確認

my $capimgdirname = $f->config->{recfolderpath} . "/" . "$tid.localized/";
#なければ作る
if (! -e $capimgdirname ){
    #FIXME!
	system("$toolpath/perl/mklocalizeddir.pl $tid");
	Foltia::Util::writelog("captureimagemaker mkdir $capimgdirname");
}

$capimgdirname .= '/img';
#なければ作る
if (! -e $capimgdirname ){
	mkdir $capimgdirname, 0777;
	Foltia::Util::writelog("captureimagemaker mkdir $capimgdirname");
}


# キャプチャ入れるディレクトリ作成 
# $captureimgdir = "$tid"."-"."$countno"."-"."$date"."-"."$time";
my $captureimgdir = $filename;
$captureimgdir =~ s/\.m2p$//; 

if (! -e "$capimgdirname/$captureimgdir"){
	mkdir "$capimgdirname/$captureimgdir" ,0777;
	Foltia::Util::writelog("captureimagemaker mkdir $capimgdirname/$captureimgdir");

}

# 変換
#system ("mplayer -ss 00:00:10 -vo jpeg:outdir=$capimgdirname/$captureimgdir/ -vf crop=702:468:6:6,scale=160:120,pp=lb -ao null -sstep 14 -v 3 $recfolderpath/$filename");

#system ("mplayer -ss 00:00:10 -vo jpeg:outdir=$capimgdirname/$captureimgdir/ -vf crop=702:468:6:6,scale=160:120 -ao null -sstep 14 -v 3 $recfolderpath/$filename");


#　ETVとか黒線入るから左右、もうすこしづつ切ろう。
#system ("mplayer -ss 00:00:10 -vo jpeg:outdir=$capimgdirname/$captureimgdir/ -vf crop=690:460:12:10,scale=160:120 -ao null -sstep 14 -v 3 $recfolderpath/$filename");

#　10秒ごとに
system ("mplayer -ss 00:00:10 -vo jpeg:outdir=$capimgdirname/$captureimgdir/ -vf crop=690:460:12:10,scale=160:120 -ao null -sstep 9 -v 3 $recfolderpath/$filename");

