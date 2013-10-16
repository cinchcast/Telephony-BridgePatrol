#!/usr/bin/php -q
<?php
//this file goes in your agi-bin directory defined in /etc/asterisk/asterisk.conf

//connect to the Pactolus db for logging
function callSQL($log)
{
   global $isconnected ;
   global $connect ;

   if ($isconnected == 0) {
     $connect = odbc_connect("PactolusServer", "sa", "8uh23ed", SQL_CUR_USE_DRIVER)
                                or die ("Could not connect to server");
     print "Connected\n";
     $isconnected = 1 ;
   }

   $query="exec psprd1.dbo.BridgePatrol_Results @TestResults = '".$log."'";
   $result = odbc_exec($connect, $query);
   return $result ;
}

$templog = "/tmp/calllog2";
$fail = "0";

//check for last call to know we're done
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
			callSQL($line);
			$fail = "1";
		}
	}
	$message .= "\n\nOn Call Instructions:\nPlace calls to the specified access numbers.\nAnalyze the failure patterns.  Is it just one platform that is down, or one specific carrier, or all calls?\n\n";
	$message .= "================================================\n\n";
	if($fail == 1)
	{
		print "One or more calls have failed\n";
		//mail('jaketullis@gmail.com', "Bridge Patrol V2", $message, 'From: BridgePatrol@cinchcast.com');
		mail('help911@cinchcast.com', "Bridge Patrol V2", $message, 'From: BridgePatrol@cinchcast.com');
		$callfile = fopen("/tmp/bridgepatrol.call", "w");
		fwrite($callfile, "Channel: SIP/66.128.12.100/16468070821\nApplication: Playback\nData: tt-weasels\nCallerID:1010101010");
		fclose($callfile);
		rename("/tmp/bridgepatrol.call","/var/spool/asterisk/outgoing/bridgepatrol.call");
	}
//	unlink($templog);
}

//log the results for later usage
if(preg_match("/log/i",$argv[1]))
{
	$file = fopen($templog, "a");
	fwrite($file, "$argv[2]\n");
	fclose($file);
}
?>
