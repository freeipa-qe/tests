#!/bin/sh


LOGDIR=$1
if [ -z $LOGDIR ];then
	echo "usage: ipa.install.sh <Log dir>"
	echo "using /tmp as log dir"
	LOGDIR=/tmp
fi

RPMS_BEFORE_IPA_INSTALL=$LOGDIR/rpms.before.txt
RPMS_AFTER_IPA_INSTALL=$LOGDIR/rpms.after..txt
RPMS_DIFF=$LOGDIR/rpms.diff.txt
IPA_RPMS=$LOGDIR/ipa.rpms.txt
IPA_FLIST=$LOGDIR/ipa.flist.txt
REPO=/etc/yum.repos.d/ipa.repo

echo "install ipa into a fresh machine"

echo "[step 1] env check..."
echo "	verity repo file"
if [ -e $REPO ] && [ -r $REPO ]
then
	echo "ipa repo file to use: [$REPO]"
	rm -rf /var/cache/yum/*
	echo "remove the yum cache"
else
	echo "no ipa repo file fount, it has to be [$REPO]"
fi

# i need some code here to check previous installation and also remove then

echo "[step 2] check privous install and remove them if there is one"

echo "[step 3] store all current installed rpms"
rpm -qa > $RPMS_BEFORE_IPA_INSTALL

echo "[step 3] yum install "
yes yes | yum install ipa-server

rpm -qa > $RPMS_AFTER_IPA_INSTALL
diff $RPMS_BEFORE_IPA_INSTALL $RPMS_AFTER_IPA_INSTALL | grep "^>" |cut -d" " -f2 >  $RPMS_DIFF
cat  $RPMS_DIFF | cut -d "." -f1 | sed "s/-[0-9]$//" > $IPA_RPMS
cat $RPMS_DIFF | xargs rpm -ql > $IPA_FLIST

echo "[step 4] install finished, you need run ipa-server-install to configura it"
echo "before ipa-server installed: [$RPMS_DIFF]"
echo "after  ipa-server installed: [$RPMS_DIFF]"
echo "rpm diff file is here: [$RPMS_DIFF]"
echo "ipa rpm list (no pkg version number) is here: [$IPA_RPMS]"
echo "ipa file list is here: [$IPA_FLIST]"
echo "DONE"
