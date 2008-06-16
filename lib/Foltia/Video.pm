package Foltia::Video;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use DBI;
use DBD::Pg;
use Schedule::At;
use Time::Local;
use Encode;
use Encode::Guess qw/utf8 euc-jp shiftjis 7bit-jis/;

__PACKAGE__->mk_accessors(qw/config/);

sub new {
    my $class = shift;
    my $config = shift;
    my $self = $class->SUPER::new(@_);
    $self->config($config);
    $self->dbh;
    $self;
}

my $dbh;
sub dbh {
    my $self = shift;
    my $data_source = sprintf("dbi:%s:dbname=%s;host=%s;port=%d",
                           $self->config->{DBDriv},
                           $self->config->{DBName},
                           $self->config->{DBHost},
                           $self->config->{DBPort},
        );
    $dbh =| DBI->connect($data_source,
                         $self->config->{DBUser},
                         $self->config->{DBPass},
        );
    $dbh;
}

sub writelog {
    Foltia::Util::writelog(@_);
}

sub getstationid {
    #引き数:局文字列(NHK総合)
    #戻り値:1
    my ($stationname) = @_;
    my $stationid ;
    my $DBQuery =  "SELECT count(*) FROM foltia_station WHERE stationname = '$item{ChName}'";

    my $sth = $self->dbh->prepare($DBQuery);
	$sth->execute();
    my @stationcount = $sth->fetchrow_array;

    if ($stationcount[0] == 1){
       #チャンネルID取得
        $DBQuery =  "SELECT stationid,stationname FROM foltia_station WHERE stationname = '$item{ChName}'";
        $sth = $self->dbh->prepare($DBQuery);
        $sth->execute();
        @stationinfo= $sth->fetchrow_array;
        #局ID
        $stationid  = $stationinfo[0];
        #print "StationID:$stationid \n";

    }
    elsif($stationcount[0] == 0){
    #新規登録
        $DBQuery =  "SELECT max(stationid) FROM foltia_station";
        $sth = $self->dbh->prepare($DBQuery);
        $sth->execute();
        @stationinfo= $sth->fetchrow_array;
        my $stationid = $stationinfo[0] ;
        $stationid  ++;
        ##$DBQuery =  "insert into  foltia_station values ('$stationid'  ,'$item{ChName}','0','','','','','','')";
        #新規局追加時は非受信局をデフォルトに
        $DBQuery =  "insert into  foltia_station  (stationid , stationname ,stationrecch )  values ('$stationid'  ,'$item{ChName}','-10')";

        $sth = $self->dbh->prepare($DBQuery);
        $sth->execute();
        #print "Add station;$DBQuery\n";
        writelog("foltialib Add station;$DBQuery");
    }
    else {

        #print "Error  getstationid $stationcount[0] stations found. $DBQuery\n";
        writelog("foltialib [ERR]  getstationid $stationcount[0] stations found. $DBQuery");
    }


    return $stationid ;
}

sub addatq {
    my ($self, $tid, $station) = @_;

    #DB検索(TIDとStationIDからPIDへ)
    if ($station == 0) {
        $DBQuery =  "SELECT count(*) FROM  foltia_tvrecord WHERE tid = '$tid'  ";
    }
    else {
        $DBQuery =  "SELECT count(*) FROM  foltia_tvrecord WHERE tid = '$tid' AND stationid  = '$station' ";
    }

    my $sth = $self->dbh->prepare($DBQuery);
	$sth->execute();
    @titlecount = $sth->fetchrow_array;
    #件数数える

    #2以上だったら
    if ($titlecount[0]  >= 2) {
	#全曲取りが含まれているか調べる
        $DBQuery =  "SELECT count(*) FROM  foltia_tvrecord WHERE tid = '$tid'  AND  stationid  ='0' ";
        my $sth = $dbh->prepare($DBQuery);
        $sth->execute();
        @reservecounts = $sth->fetchrow_array;

        if($reservecounts[0] >= 1 ){#含まれていたら
            if($tid == 0){
                #今回の引き数がSID 0だったら
                #全局取りだけ予約
                # &writelog("addatq  DEBUG; ALL STATION RESERVE. TID=$tid SID=$station $titlecount[0] match:$DBQuery");
                $self->addcue;
            }
            else {
                #ほかの全局録画addatqが予約入れてくれるからなにもしない
                # &writelog("addatq  DEBUG; SKIP OPERSTION. TID=$tid SID=$station $titlecount[0] match:$DBQuery");
                exit;
            }#end if ふくまれていたら
        }#endif 2つ以上	
    }
    elsif($titlecount[0]  == 1) {
		$self->addcue;
    }
    else {
        writelog("addatq  error; reserve impossible . TID=$tid SID=$station $titlecount[0] match:$DBQuery");
    }
}

sub addcue{
    my $self = shift;
    if ($station == 0) {
        $DBQuery =  "SELECT * FROM  foltia_tvrecord WHERE tid = '$tid'  ";
    }
    else {
        $DBQuery =  "SELECT * FROM  foltia_tvrecord WHERE tid = '$tid' AND stationid  = '$station' ";
    }

    my $sth = $self->dbh->prepare($DBQuery);
    $sth->execute();

    my @titlecount= $sth->fetchrow_array;
    my $bitrate = $titlecount[2];#ビットレート取得

    #PID抽出
    my $now = &epoch2foldate(`date +%s`);
    my $twodaysafter = &epoch2foldate(`date +%s` + (60 * 60 * 24 * 2));
    #キュー入れは直近2日後まで

    if ($station == 0 ){
        $DBQuery =  "
SELECT * from foltia_subtitle WHERE tid = '$tid'  AND startdatetime >  '$now'  AND startdatetime < '$twodaysafter' ";

    }
    else {
        $DBQuery =  "
SELECT * from foltia_subtitle WHERE tid = '$tid' AND stationid  = '$station'  AND startdatetime >  '$now'  AND startdatetime < '$twodaysafter' ";
        #stationIDからrecch
        my $getrecchquery = "SELECT stationid , stationrecch  FROM foltia_station where stationid  = '$station' ";
        my $stationh = $self->dbh->prepare($getrecchquery);
        $stationh->execute();
        my @stationl =  $stationh->fetchrow_array;
        my $recch = $stationl[1];
    }

    $sth = $self->dbh->prepare($DBQuery);
	$sth->execute();
 
    while (($pid ,
            $tid ,
            $stationid ,
            $countno,
            $subtitle,
            $startdatetime,
            $enddatetime,
            $startoffset ,
            $lengthmin,
            $atid )
           = $sth->fetchrow_array()) {

        if ($station == 0 ){
            #stationIDからrecch
            $getrecchquery="SELECT stationid , stationrecch  FROM foltia_station where stationid  = '$stationid' ";
            $stationh = $dbh->prepare($getrecchquery);
            $stationh->execute();
            @stationl =  $stationh->fetchrow_array;
            $recch = $stationl[1];
        }
        #キュー入れ
        #プロセス起動時刻は番組開始時刻の-1分
        $atdateparam = Foltia::Utils::calcatqparam(300);
        $reclength = $lengthmin * 60;
        #&writelog("TIME $atdateparam COMMAND $toolpath/perl/tvrecording.pl $recch $reclength 0 0 $bitrate $tid $countno");
        #キュー削除
        Schedule::At::remove ( TAG => "$pid"."_X");
        writelog("addatq remove $pid");
        if ( $ARGV[2] eq "DELETE"){
            writelog("addatq remove  only $pid");
        }
        else {
            Schedule::At::add (TIME => "$atdateparam", COMMAND => "$toolpath/perl/folprep.pl $pid" , TAG => "$pid"."_X");
            writelog("addatq TIME $atdateparam   COMMAND $toolpath/perl/folprep.pl $pid ");
        }
##processcheckdate 
#&writelog("addatq TIME $atdateparam COMMAND $toolpath/perl/schedulecheck.pl");
    }#while



}#endsub


sub addpidatq {
    my $self = shift;
    my $pid = shift;

    #DB検索(PID)
    $DBQuery =  "SELECT count(*) FROM  foltia_subtitle WHERE pid = '$pid' ";
    my $sth = $self->dbh->prepare($DBQuery);
	$sth->execute();
    my @titlecount= $sth->fetchrow_array;
 
    if ($titlecount[0]  == 1 ) {
        $DBQuery =  "SELECT bitrate FROM  foltia_tvrecord , foltia_subtitle  WHERE foltia_tvrecord.tid = foltia_subtitle.tid AND pid='$pid' ";
        $sth = $self->dbh->prepare($DBQuery);
        $sth->execute();
        @titlecount= $sth->fetchrow_array;
        $bitrate = $titlecount[0];#ビットレート取得

        #PID抽出
        $now = Foltia::Util::epoch2foldate(`date +%s`);

        $DBQuery =  "SELECT stationrecch FROM foltia_station,foltia_subtitle WHERE foltia_subtitle.pid = '$pid'  AND  foltia_subtitle.stationid =  foltia_station.stationid ";


        #stationIDからrecch
        $stationh = $self->dbh->prepare($DBQuery);
        $stationh->execute();
        @stationl =  $stationh->fetchrow_array;
        $recch = $stationl[0];

        $DBQuery =  "SELECT  * FROM  foltia_subtitle WHERE pid='$pid' ";
        $sth = $self->dbh->prepare($DBQuery);
        $sth->execute();
        ($pid ,
         $tid ,
         $stationid ,
         $countno,
         $subtitle,
         $startdatetime,
         $enddatetime,
         $startoffset ,
         $lengthmin,
         $atid ) = $sth->fetchrow_array();
         # print "$pid ,$tid ,$stationid ,$countno,$subtitle,$startdatetime,$enddatetime,$startoffset ,$lengthmin,$atid \n";

        if($now< $startdatetime){#放送が未来の日付なら
            #もし新開始時刻が15分移譲先なら再キュー
            $startafter = &calclength($now,$startdatetime);
            writelog("addpidatq DEBUG \$startafter $startafter \$now $now \$startdatetime $startdatetime");

            if ($startafter > 14 ){
                #キュー削除
                Schedule::At::remove ( TAG => "$pid"."_X");
                writelog("addpidatq remove que $pid");

                #キュー入れ
                #プロセス起動時刻は番組開始時刻の-5分
                $atdateparam = Foltia::Util::calcatqparam(300);
                Schedule::At::add (TIME => "$atdateparam", COMMAND => "$toolpath/perl/folprep.pl $pid" , TAG => "$pid"."_X");
                writelog("addpidatq TIME $atdateparam   COMMAND $toolpath/perl/folprep.pl $pid ");
            }
            else {
                $atdateparam = Foltia::Util::calcatqparam(60);
                $reclength = $lengthmin * 60;

                #キュー削除
                Schedule::At::remove ( TAG => "$pid"."_R");
                writelog("addpidatq remove que $pid");

                if ($countno eq "") {
                    $countno = "0";
                }

                Schedule::At::add (TIME => "$atdateparam", COMMAND => "$toolpath/perl/recwrap.pl $recch $reclength  $bitrate $tid $countno $pid" , TAG => "$pid"."_R");
                writelog("addpidatq TIME $atdateparam   COMMAND $toolpath/perl/recwrap.pl $recch $reclength  $bitrate $tid $countno $pid");

            }#end #もし新開始時刻が15分移譲先なら再キュー
        }
        else {
            writelog("addpidatq drop:expire  $pid  $startafter  $now  $startdatetime");
        }#放送が未来の日付なら

    }
    else {
        warn "error record TID=$tid SID=$station $titlecount[0] match:$DBQuery\n";
        writelog("addpidatq error record TID=$tid SID=$station $titlecount[0] match:$DBQuery");

    }#end if ($titlecount[0]  == 1 ){
}


sub deletemovie {
    my ($self, $file) = @_;
    #ファイル名正当性チェック
    if (! $file =~ /.m2p\z/){
    #	print "deletemovie invalid filetype.\n";
        my $msg = "deletemovie invalid filetype: $file.";
        writelog($msg);
        warn $msg;
        return 0;
    }

    #ファイル存在チェック
    my $filepath = $self->config->recfolderpath . $file;
    if (-e $filepath) {
    # print "deletemovie file not found.$recfolderpath/$fname\n";
        my $msg = "deletemovie file not found: $file.";
        writelog($msg);
        warn $msg;
        return 0;
    }

    #既読削除処理
    if ($self->config->rapidfiledelete > 0){ #./mita/へ移動
        my $trashpath = $self->config->trashpath;
        system ("mv $filepath $trashpath");
        writelog("deletemovie mv $filepath $trashpath.");
    }else{ #即時削除
        system ("rm $filepath");
        writelog("deletemovie rm $filepath ");
    }
}

sub mklocalizeddir {
    my ($self, $tid) = @_;

    #そのディレクトリがなければ
    my $dirname = $self->config->recfolderpath . $tid . '.localized';
    return 0 if (-e $dirname);

    #.localized用文字列取得

    #検索
    my $DBQuery =  "select title from foltia_program where tid=$tid ";
    my $sth = $self->dbh->prepare($DBQuery);
	$sth->execute();
    my @subticount= $sth->fetchrow_array;
    my $title = $subticount[0];

	mkdir ("$dirname",0755);
	mkdir ("$dirname/.localized",0755);
	mkdir ("$dirname/mp4",0755);
	mkdir ("$dirname/m2p",0755);
	open (JASTRING,">$dirname/.localized/ja.strings")  || die "Cannot write ja.strings.\n";
	print JASTRING "\"$tid\"=\"$title\";\n";
	close(JASTRING);

    my $utf8title = decode("Guess", $title);
    #writelog("mklocalizeddir $tid " . encode('utf8', $utf8title));
    writelog("mklocalizeddir $tid " . encode('euc-jp', $utf8title));
}

1;
