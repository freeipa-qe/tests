
# Created 11-30-2010 by mgregg@redhat.com

The bash script needs to run in cron. I suggest copying the bash file to /root.

Then, edit roots crotab with "crontab -e" as the root user. 

Put the following into the root's cron.

17 22 1-5 * * /root/launch_acceptance.bash
15 20 1-5 * * /root/rebuild-tests.bash

For the ipa-server certification, I want it to run every 3 hours during work hours only, mon-fri only

1 5,8,11,14,16 1-5 * * /root/ipa-server-rhel6.1-cert.bash
