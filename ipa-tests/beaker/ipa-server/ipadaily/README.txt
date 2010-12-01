
# Created 11-30-2010 by mgregg@redhat.com

The bash script needs to run in cron. I suggest copying the bash file to /root.

Then, edit roots crotab with "crontab -e" as the root user. 

Put the following into thec cron.

3 20 * * * /root/launch_acceptance.bash



