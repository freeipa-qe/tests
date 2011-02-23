
# Created 11-30-2010 by mgregg@redhat.com

The bash script needs to run in cron. I suggest copying the bash file to /root.

Then, edit roots crotab with "crontab -e" as the root user. 

Put the following into the root's cron.

15 20 * * * /root/rebuild-tests.bash
17 22 * * * /root/launch_acceptance.bash

For the ipa-server certification, I want it to run every 3 hours during work hours only

1 3,6,9,12,15 * * * /root/ipa-server-rhel6.1-cert.bash
