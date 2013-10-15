## Setup

We will assume that everything is in the default locations. First, you need to take the file extensions_custom.conf and either add it to your own custom extensions file, or create one yourself.

You will need this line in your /etc/asterisk/extensions.conf file. 

```
	#include extensions_custom.conf
```
Now add the contents of our extensions_custom.conf to the end of the existing one. If you are only using version 2, and will be assumed for the rest of this readme, only copy the version 2 section. 

Next, we have to put bridgepatrol2.php in the appropriate agi-bin directory as defined in /etc/asterisk/asterisk.conf under "astagidir". 

On most systems this directory is /var/lib/asterisk/agi-bin. Ensure that it is chmodded to the proper permissions as well. 

Finally, you will need to edit bridgepatrol2.cfg to add the conference bridges you wish to test. Config should look as follows:

>Number@Ip With Extra Info

Here is an example config
```
15554443333@10.0.0.1 Conference Bridge 1
15552229999@10.0.0.2 Conference Bridge 2
```
Now, all you should have to do is add bridgepatrol2.pl and bridgepatrol2.cfg to your /home/blogtalk directory and add bridgepatrol2.pl to cron. Don't forget to chmod bridgepatrol2.pl. Do not set the interval lower than 3 minutes as we need to ensure all calls get placed and finish before another set starts. 

## Notable lines in code

Lines 8-13 of bridgepatrol2.pl can be changed to accommodate different file locations if needed. 

Line 47 of bridgepatrol2.php can be changed or duplicated to send emails as wished. 



