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
    return $__log;
}

sub writelog {
    log->write(@_);
}
#end writelog

sub syobocaldate2foltiadate {
#20041114213000 -> 200411142130
    my ($foltiadate) = @_;
    $foltiadate = unpack ('A12', $foltiadate);
    return $foltiadate;
}

sub foldate2epoch{
    my ($foltiadate) = @_;
    #EPGをEPOCに
    # 2004 11 14 21 30
    my ($eyear, $emon, $emday, $q_start_time_hour, $q_start_time_min)
        = unpack 'A4 A2 A2 A2 A2', $foltiadate;
    $emon--;
    my $epoch = timelocal(0, $q_start_time_min, $q_start_time_hour, 
                              $emday, $emon, $eyear);
    return $epoch;
}


sub epoch2foldate{
    my ($s, $mi, $h, $d, $mo, $y, $w) = localtime($_[0]);
    $mo++; $y += 1900;

    my $foltiadate;
    $foltiadate = sprintf("%04d%02d%02d%02d%02d", $y, $mo, $d, $h, $mi);

    return $foltiadate;
}

sub calclength {
    #foltia開始時刻、folti終了時刻
    #戻り値:分数
    my ($sttime, $edtime) = @_;
    my $length = -1;
    $length = abs( foldate2epoch($edtime) - foldate2epoch($sttime) );

    return $length / 60;
}

sub calcoffsetdate {
    #引き数:foltia時刻、オフセット(+/-)分
    #戻り値]foltia時刻
    my ($foltime, $offsetmin) = @_;

    my $epoch = foldate2epoch($foltime);
    $epoch = $epoch + ($offsetmin * 60);
    $foltime = epoch2foldate($epoch);
    return $foltime;
}

sub calcatqparam {
    my ($seconds) = @_;
    my $processstarttimeepoch = "";
	$processstarttimeepoch = foldate2epoch($startdatetime);
	$processstarttimeepoch = $processstarttimeepoch - $seconds;
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)
        = localtime($processstarttimeepoch);
	$year += 1900;
	$mon++; #範囲を0-11から1-12へ
    my $atdateparam = "";
	$atdateparam = sprintf("%04d%02d%02d%02d%02d",$year,$mon,$mday,$hour,$min);	

    return $atdateparam;
}

sub processfind{
    my ($findprocess) = @_;

    my @processes = qx{ps ax | grep -i $findprocess};
    my $chkflag = 0;

    foreach (@processes){
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
    return $chkflag;
}#endsub


sub filenameinjectioncheck {
    my ($self, $filename) = @_;
    $filename =~ s/\///gi;
    $filename =~ s/\;//gi;
    $filename =~ s/\&//gi;
    $filename  =~ s/\|//gi;

    return $filename;
}

sub getphpstyleconfig {
    my ($key) = @_;
    my $phpconfigpath = File::Spec->catfile( $FindBin::Bin );
    my $configline = "";
    # read
    if (-e "$phptoolpath/foltia_config2.php") {
        $phpconfigpath = "$phptoolpath/php/foltia_config2.php";
    }
    elsif(-e "$toolpath/php/foltia_config2.php") {
        $phpconfigpath = "$toolpath/php/foltia_config2.php";
    }
    else {
        $phpconfigpath = qx{locate foltia_config2.php | head -1};
        chomp($phpconfigpath);
    }


    if (-r $phpconfigpath ) {
        open my $config ,'<' , "$phpconfigpath" or die "File cannot read.$!";
        while(<$config>){
            if (/$key/){
                $configline = $_;
                $configline =~ s/\/\/.*$//;
                $configline =~ s/\/\*.*\*\///;
            }
        }
        close $config;
    }#end if -r $phpconfigpath 

    return $configline;
}#end sub getphpstyleconfig

1;
__END__

