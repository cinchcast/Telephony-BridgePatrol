#!/usr/bin/php -q
//this file goes in your agi-bin directory defined in /etc/asterisk/asterisk.conf
<?php

$templog = "/tmp/calllog";
$fail = "0";

if(preg_match("/last/i",$argv[1]))
{
	sleep(60);
	$file = file($templog);
	$message = "=================================================\n\n";
	$message .= "Alarm Time: ".date(DATE_RFC822)."\n\nOne or more of the following test calls to a conference bridge did not complete:\n\n";
	foreach($file as $line)
	{
		$message .= $line;
		if(!preg_match("/Success/i",$line))
		{
			$fail = "1";
		}
	}
	$message .= "\n\nOn Call Instructions:\nPlace calls to the specified access numbers.\nAnalyze the failure patterns.  Is it just one platform that is down, or one specific carrier, or all calls?\n\n";
	$message .= "================================================\n\n";
	if($fail == 1)
	{
		print "One or more calls have failed\n";
		mail('jaketullis@gmail.com', "Production Bridge Call Testing Alert", $message, 'From: BridgePatrol@cinchcast.com');
		mail('help@cinchcast.com', "Production Bridge Call Testing Alert", $message, 'From: BridgePatrol@cinchcast.com');
//		$callfile = fopen("/tmp/bridgepatrol.call", "w");
//		fwrite($callfile, "Channel: SIP/66.128.12.100/16468070821\nApplication: Playback\nData: tt-weasels\nCallerID:1010101010");
//		fclose($callfile);
//		rename("/tmp/bridgepatrol.call","/var/spool/asterisk/outgoing/bridgepatrol.call");
	}
//	unlink($templog);
}
if(preg_match("/log/i",$argv[1]))
{
	$file = fopen($templog, "a");
	fwrite($file, "$argv[2]\n");
	fclose($file);
}
else
{
	mail('jaketullis@gmail.com', "Error in bridgepatrol script", $argv[1]." ".$argv[2]." ".$argv[3]);
}
?>
