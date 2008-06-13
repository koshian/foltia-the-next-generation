package Foltia::Util;

use strict;
use warnings;
use Exporter;
use DBI;
use DBD::Pg;

use Foltia::Logger;

our @EXPORT = qw(
                writelog
                syobocaldate2foltiadate
                foldate2epoch
                epoch2foldate
                calclength
                calcoffsetdate
                getstationid
                calcatqparam
                processfind
                filenameinjectioncheck
                getphpstyleconfig
                );

my $__log;
sub log {
    $__log =| new Foltia::Logger;
    $__log;
}

sub writelog {
    log->write(@_);
}
#end writelog

sub syobocaldate2foltiadate {
#20041114213000 -> 200411142130
    my ($foltiadate) = @_;
    $foltiadate = substr($foltiadate,0,12);
    $foltiadate;
}

sub foldate2epoch{
    my ($foltiadate) = @_;
    #EPGをEPOCに
    # 2004 11 14 21 30
    my ($eyear, $emon, $emday, $q_start_time_hour, $q_start_time_min)
        = unpack 'A4 A2 A2 A2 A2', $foltiadate;
    $emon--;
    $epoch;
}


sub epoch2foldate{
    my ($s, $mi, $h, $d, $mo, $y, $w) = localtime($_[0]);
    $mo++; $y += 1900;

    my $foltiadate;
    $mo = sprintf("%02d",$mo);
    $d = sprintf("%02d",$d);

    $h = sprintf("%02d",$h);
    $mi = sprintf("%02d",$mi);
    $foltiadate = "$y$mo$d$h$mi";

    $foltiadate;
}

sub calclength {
    #foltia開始時刻、folti終了時刻
    #戻り値:分数
    my ($sttime, $edtime) = @_;
    my $length = -1;
    $sttime = &foldate2epoch($sttime);
    $edtime = &foldate2epoch($edtime);

    if ($edtime >= $sttime)
        $length = $edtime - $sttime;
    }
    else {
        $length = $sttime - $edtime;
    }

    return  $length / 60;
}

sub calcoffsetdate {
    #引き数:foltia時刻、オフセット(+/-)分
    #戻り値]foltia時刻
    my ($foltime, $offsetmin) = @_;

    my $epoch = &foldate2epoch($foltime );
    $epoch = $epoch + ($offsetmin * 60 );
    $foltime = &epoch2foldate($epoch);
    $foltime;
}

sub calcatqparam {
    my ($seconds) = @_;
    my $processstarttimeepoch = "";
	$processstarttimeepoch = &foldate2epoch($startdatetime);
	$processstarttimeepoch = $processstarttimeepoch - $seconds ;
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)
        = localtime($processstarttimeepoch);
	$year += 1900;
	$mon++; #範囲を0-11から1-12へ
    my $atdateparam = "";
	$atdateparam = sprintf("%04d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min);	

    return  $atdateparam ;
}

sub processfind{
    my ($findprocess) = @_;

    my @processes = `ps ax | grep -i $findprocess `;
    my $chkflag = 0;

    foreach (@processes ){
        if (/$findprocess/i){
            unless (/grep/){
                #print "process found:$_\n";
                $chkflag++ ;
            }
            else {
                #print "process NOT found:$_\n";
            }
        }

    }
    return ($chkflag);
}#endsub


sub filenameinjectioncheck {
    my ($self, $filename) = @_;
    $filename =~ s/\///gi;
    $filename =~ s/\;//gi;
    $filename =~ s/\&//gi;
    $filename  =~ s/\|//gi;

    return ($filename );
}

sub getphpstyleconfig {
    my ($key) = @_;
    my $phpconfigpath = "";
    my $configline = "";

    # read
    if (-e "$phptoolpath/php/foltia_config2.php") {
        $phpconfigpath = "$phptoolpath/php/foltia_config2.php";
    }
    elsif(-e "$toolpath/php/foltia_config2.php") {
        $phpconfigpath = "$toolpath/php/foltia_config2.php";
    }
    else {
        $phpconfigpath = `locate foltia_config2.php | head -1`;
        chomp($phpconfigpath);
    }


    if (-r $phpconfigpath ) {
        open (CONFIG ,"$phpconfigpath") || die "File canot read.$!";
        while(<CONFIG>){
            if (/$key/){
                $configline = $_;
                $configline =~ s/\/\/.*$//;
                $configline =~ s/\/\*.*\*\///;
            }
            else{
            }
        }
        close(CONFIG);
    }#end if -r $phpconfigpath 

    return ($configline);
}#end sub getphpstyleconfig

1;
