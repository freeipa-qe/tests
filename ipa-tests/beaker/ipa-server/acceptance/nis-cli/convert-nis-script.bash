# Manual nis conversion script
# To be run manually after the nis-cli tests have been run.
# This test is to be run on the client containing the working nis server.
# before you run this test, you should be able to run "ypcat passwd" and get a output similar to:
#jaKob:asdfghjk:503:503::/home/jaKob:/bin/bash
#joe2:asdfghjk:502:502::/home/joe2:/bin/bash
#littleu:asdfghjk:504:504::/home/littleu:/bin/bash
#test:$6$oIW3o2Mr$XbWZKaM7nA.cQqudfDJScupXOia5h1u517t6Htx/Q/MgXm82Pc/OcytatTeI4ULNWOMJzvpCigWiL4xKP9PX4.:500:500::/home/test:/bin/bash
#joe1:asdfghjk:501:501::/home/joe1:/bin/bash
# Michael Gregg

. /dev/shm/env.sh
. /dev/shm/ipa-server-shared.sh

KinitAsAdmin

ypcat -d $NISDOMAIN -h 127.0.0.1 passwd  | while read users; do
	user=$(echo $users | cut -d: -f1)
	uid=$(echo $users | cut -d: -f3)
	gid=$(echo $users | cut -d: -f4)
	title=$(echo $users | cut -d: -f5)
	home=$(echo $users | cut -d: -f6)
	shell=$(echo $users | cut -d: -f7)
	echo "user=$user uid=$uid gid=$gid home=$home shell=$shell"
	ipa user-add --first=$user --last=$user --uid=$uid --gid=$gid --homedir=$home --shell=$shell --title=$title $user 
done
	

