#!/usr/bin/perl
use Time::HiRes qw(usleep nanosleep);
use File::Copy;

# Loren doesn't want to delete the temp log file until the next time this script is invoked; makes for easier debugging.
print "Clearing out old call log\n";
unlink "/tmp/calllog";

$tmppath = "/var/spool/asterisk/gencalltmp/";  # We create the call file here.
mkdir $tmppath;
$outpath = "/var/spool/asterisk/outgoing/";   # Then move it to this directory, where asterisk picks it up.

open(CFG, "</home/blogtalk/bridgepatrol.cfg") || die $!;
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
			print CALLFILE "Channel: Local/10\nContext: default\nExtension: 11\nSetvar: numcalled=$pnumber\nSetvar: peerip=$ipaddr\nSetvar: last=yes\nSetvar: info=$desc";
			close CALLFILE;
			move($tmppath.$callfile, $outpath.$callfile);
			print "Last - Created callfile for ".$pnumber."@".$ipaddr." ".$desc."\n";
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
         open(CALLFILE, ">".$tmppath.$callfile) || die $!;         print CALLFILE "Channel: Local/10\nContext: default\nExtension: 11\nSetvar: numcalled=$pnumber\nSetvar: peerip=$ipaddr\nSetvar: last=no\nSetvar: info=$desc";
         close CALLFILE;
			move($tmppath.$callfile, $outpath.$callfile) || die $!;			
			print "Created callfile for ".$pnumber."@".$ipaddr." ".$desc."\n";
			usleep(500000);
		}
	}
}
