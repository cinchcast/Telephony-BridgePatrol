#!/usr/bin/perl
use Time::HiRes qw(usleep nanosleep);
use File::Copy;

#Clear out the old log file 
print "Clearing out old call log\n";
unlink "/tmp/calllog2";

$tmppath = "/var/spool/asterisk/gencalltmp/";  # We create the call file here.
mkdir $tmppath;
$outpath = "/var/spool/asterisk/outgoing/";   # Then move it to this directory, where asterisk picks it up.

open(CFG, "</home/blogtalk/bridgepatrol2.cfg") || die $!; #this file holds all the calls to execute
@lines = <CFG>;
$count = scalar @lines;
for $i (0..@lines-1)
{
        for($lines[$i])
        {
                if($i == $count-1)
                {
                  #last call routine
                  @words = split(" ",$_,2);
                  @info = split("@",$words[0]);
                  $desc = $words[1];
                  $ipaddr = $info[1];
                  $pnumber = $info[0];
                  chomp($desc);
                  chomp($ipaddr);
                  chomp($pnumber);
                  $callfile = int(rand(9999)).".call";
                  open(CALLFILE, ">".$tmppath.$callfile) || die $!;
                  print CALLFILE "Channel: Local/66\@bridgepatrol\nContext: bridgepatrol\nExtension: 67\nSetvar: numcalled=$pnumber\nSetvar: peerip=$ipaddr\nSetvar: last=yes\nSetvar: info=$desc";
                  close CALLFILE;
                  move($tmppath.$callfile, $outpath.$callfile) || die $!;
                  print "Last - Created callfile for ".$pnumber."@".$ipaddr." ".$desc." ".$callfile."\n";
                }
                else
                {
                	@words = split(" ",$_,2);
                	@info = split("@",$words[0]);
                	$desc = $words[1];
                	$ipaddr = $info[1];
                	$pnumber = $info[0];
                	chomp($desc);
                	chomp($ipaddr);
                	chomp($pnumber);
					 	$callfile = int(rand(9999)).".call";
		         	open(CALLFILE, ">".$tmppath.$callfile) || die $!;
      		   	print CALLFILE "Channel: Local/66\@bridgepatrol\nContext: bridgepatrol\nExtension: 67\nSetvar: numcalled=$pnumber\nSetvar: peerip=$ipaddr\nSetvar: last=no\nSetvar: info=$desc";
         			close CALLFILE;
                  move($tmppath.$callfile, $outpath.$callfile) || die $!;
                	print "Created callfile for ".$pnumber."@".$ipaddr." ".$desc." ".$callfile."\n";
                  usleep(500000);
                }
        }
}

