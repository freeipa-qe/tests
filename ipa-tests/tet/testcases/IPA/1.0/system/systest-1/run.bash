#!/bin/bash


# do this separately on the master and replica

i=0

while [ $i -le 10000 ];
do

# Add user
ipa-adduser -f "A-$i" -l "A-$i" -p "redhat"  A-$i
# Add group
ipa-addgroup -d "group desc $i" Grp-$i

# add user to group
ipa-modgroup -a user-$i Grp-$i

# invoke a memberof Search
ipa-findgroup Grp-$i

i=`expr $i + 1`
done
