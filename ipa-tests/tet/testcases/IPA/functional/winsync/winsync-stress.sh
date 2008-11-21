#!/bin/sh

. ./winsync-libs.sh

echo "Please make sure:
1. test machine is one of ipa master, replica 1, replica 2, replica 3
2. exchange ssh genkey, (passwordless communication)
3. AD<-->IPA winsync agreement has been established
"

echo "step 1. create users on ipa server"
echo "step 2. create users on ad server"
echo "step 3. wait till they sync"
echo "step 4. sychonization test starts..."
echo "step 4-1. lock/unlock check"
echo "step 4-2. telephone field check"
echo "step 4-3. other field check"

echo ""
echo redhat123 | kinit admin > /dev/null 2>&1

h=$1
total=$2
base=10000

if [ -z $h ];then
	h="z"
fi
if [ -z $total ];then
	total=10
fi

echo "h=[$h] total=[$total]"
echo "add users on both AD and IPA"

for (( i = 0 ; i<= $total; i++ ))
do
	((uid=base+i))
	firstname=$uid
	lastname=$h
	username=$lastname$firstname
	ipa_adduser "$IPAUSER_DEFAULT_homedir/$username" $firstname $lastname $IPAUSER_DEFAULT_password $IPAUSER_DEFAULT_shell $username
	ad_adduser $firstname $lastname $username
done

echo "unlock all users from IPA"
for (( i = 0 ; i<= $total; i++ ))
do
        ((uid=base+i))
        firstname=$uid
        lastname=$h
        username=$lastname$firstname
        ipa-lockuser --unlock $username 
done

echo "delete users from AD/IPA"
for (( i = 0 ; i<= $total; i++ ))
do
        ((uid=base+i))
        firstname=$uid
        lastname=$h
        username=$lastname$firstname
        #ipa_deluser $username
        #ad_deluser $firstname $lastname
done


