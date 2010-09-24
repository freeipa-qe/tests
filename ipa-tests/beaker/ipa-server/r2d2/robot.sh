#!/bin/bash

# Data: 1/13/2010
# By  : yzhang@redhat.com

while [ ! -d $TET/testcases ]
do
    if [ ! -z $TET ];then
        echo "verify TET value... [$TET/testcases] not found"
    fi
    echo -n "TET root:"
    read TET
done
echo "using TET=[$TET]"
export TET

. ./robot.conf

TESTSUITE=$1
if [ -z $TESTSUITE ];then
	echo "usage: robot.sh <test_suite_name>"
	echo -n "test suite name: "
	read TESTSUITE
fi

# create a template directory in $TMP directory
DIR="$TMP/$TESTSUITE.$RANDOM"
mkdir $DIR
if [ -d $DIR ]
then
	echo "[$DIR] directory created"
else
	echo "[$DIR] can not be created, exit"
	exit
fi

echo "1. Please verify the following configuration:"
if   [ ! -z $TESTSUITE ]	\
  && [ -w $ACCEPTANCE ]		\
  && [ -r $ENGAGE_TEMPLATE ]	\
  && [ -r $TETSCEN_TEMPLATE ]	\
  && [ -r $TETSCRIPT_TEMPLATE ]
then
	echo "test suite         :[$TESTSUITE]"
	echo "engate template    :[$ENGAGE_TEMPLATE]"
	echo "tet_scen template  :[$TETSCEN_TEMPLATE]"
	echo "tet script template:[$TETSCRIPT_TEMPLATE]"
	echo -n "continue? [y/n]"
	read choice
	if [ ! $choice = y ];then
		exit
	fi
fi

echo -n "2. insert test suite info into acceptance test script..."
sed	-e 's/# callrobot_include/. $mainRunBaseDir\/'$TESTSUITE'\/engage.'$TESTSUITE'.sh\n\# callrobot_include/' \
	-e 's/# callrobot_default/\t'$TESTSUITE'_default\n\# callrobot_default/'\
	-e 's/# callrobot_ask/\t\t'$TESTSUITE'_ask\n\# callrobot_ask/'\
	-e 's/# callrobot_print/\t\t'$TESTSUITE'_print\n\# callrobot_print/'\
	-e 's/# callrobot_save/\t'$TESTSUITE'_save\n\# callrobot_save/'\
	-e 's/# callrobot_check/\t\t'$TESTSUITE'_check\n\# callrobot_check/'\
	-e 's/# callrobot_run/TET_SUITE_ROOT=$mainRunBaseDir\/'$TESTSUITE'; export TET_SUITE_ROOT\nif [ $MainRunStartup = y ] ; then '$TESTSUITE'_startup ; fi\nif [ $MainRunTests = y ]   ; then '$TESTSUITE'_run     ; fi\nif [ $MainRunCleanup = y ] ; then '$TESTSUITE'_cleanup ; fi\n\n\# callrobot_run/'\
	$ACCEPTANCE > $DIR/engage.acceptance.sh
chmod +x $DIR/engage.acceptance.sh
echo " done"

echo -n "3. make engage.$TESTSUITE.sh file ..."
d=`date "+%F"`
sed	-e 's/callrobot/'$TESTSUITE'/' \
	-e 's/callrobotRunIt/'$TESTSUITE'RunIt/' \
	-e 's/DATE/'$d'/' \
	$ENGAGE_TEMPLATE > $DIR/engage.$TESTSUITE.sh
chmod +x $DIR/engage.$TESTSUITE.sh
echo " done"

echo -n "4. make tet_scen.sh file ..."
sed	-e 's/callrobot/'$TESTSUITE'/' $TETSCEN_TEMPLATE > $DIR/tet_scen.sh
chmod +x $DIR/tet_scen.sh
echo " done"

echo -n "5. make $TESTSUITE.sh ..."
sed	-e 's/callrobot/'$TESTSUITE'/' \
	-e 's/DATE/'$d'/' \
	-e 's/DIRcallrobot/DIR'$TESTSUITE'/' \
	$TETSCRIPT_TEMPLATE > $DIR/$TESTSUITE.sh
chmod +x $DIR/$TESTSUITE.sh
echo " done"

echo "---- the following file generated in [$DIR] ----"
ls -l $DIR
echo "---------------------------------------"
echo "allmost done, please verify the automatic generated file, and do:"
echo "cp $DIR/engage.accetpance.sh $ACCEPTANCE"
echo "cp $DIR/engage.$TESTSUITE.sh $BASE/$TESTSUITE/."
echo "cp $DIR/tet_scen.sh $BASE/$TESTSUITE/."
echo "cp $DIR/$TESTSUITE.sh $BASE/$TESTSUITE/."
