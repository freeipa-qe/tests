#!/bin/sh
# File: r2d2.sh
# Date: Setp 19, 2010
# Author: yi zhang (yzhang@redhat.com)

# r2d2.sh will read file from ./template directory and make test suite files based on the given conf file, a given sample is r2d2.conf

# check the configuration file
CONF=$1
if [ -z "$CONF" ];then
	echo "usage: r2d2.sh <test_suite_conf file>"
	echo -n "test suite configuration file: "
	read CONF
fi

if [ -r "$CONF" ];then
    echo "configuration file: [$CONF]"
    . $CONF
else
    echo "no configurationn file provides, exit"
    exit 0
fi

# checking to ensure that manifest file exists
if [ ! -f $manifest ]
then
    echo "WARNING - manifest file $manifest not found"
fi

# check the starting point: where we have acceptance test stored
while [ ! -d $RHTS/r2d2 ]
do
    echo -n "RHTS root: "
    read RHTS
    if [ ! -d $RHTS/r2d2 ];then
        echo "verify RHTS value... [$RHTS/r2d2] not found"
    fi
done
export RHTS
echo "using RHTS=[$RHTS]"
echo "r2d2 root=[$RHTS/r2d2]"
r2d2=$RHTS/r2d2
template=$r2d2/template

# verify source template directory

# prepare output directory
now=`date "+%Y%m%d_%H%M" `
out="$r2d2/out/${testsuitename}.${now}"
echo "output dir: [$out]"

if [ ! -d $r2d2/$out ];then
    mkdir -p $out
else
    echo -n "clean [$out] (y/n) y ?"
    read answer
    if [ -z "$answer" ] || [ "$answer" = "y" ];then
        rm -rf $out
    else
        echo "do nothing. No output directory defined. You can wait for one minutes to rerun this program"
        exit 1
    fi
fi
echo "output directory : [$out]"

# display the template file (template source of this script)
makefile_template=$template/Makefile.template
purpose_template=$template/PURPOSE.template
testinfo_template=$template/testinfo.template
runtest_template=$template/runtest.template

# output file (destination)
makefile_out=$out/Makefile
purpose_out=$out/PURPOSE
testinfo_out=$out/testinfo.desc
runtest_out=$out/runtest.sh
t_out=$out/t.${testsuitename}.sh

if [ -r $lib_template ] \
    && [ -r $makefile_template ]\
    && [ -r $purpose_template ] \
    && [ -r $runtest_template ] \
    && [ -r $testinfo_template ]\
    && [ -r $menifest ]
then
    echo "template used in this test:"
    echo "template for Makefile:        [$makefile_template]"
    echo "template for PURPOSE :        [$purpose_template]"
    echo "template for testinfo.desc:   [$testinfo_template]"
    echo "template for runtest.sh:      [$runtest_template]"
    echo "manifest for test case:       [$manifest]"

    echo "output file goes to:"
    echo "Makefile:        [$makefile_out]"
    echo "PURPOSE :        [$purpose_out]"
    echo "testinfo.desc:   [$testinfo_out]"
    echo "runtest.sh:      [$runtest_out]"
    echo "test case:       [$t_out]"
fi

echo "------------------------------------------------"

########################################
#    produce: Makefile                 #
########################################
sed -e "s/r2d2_authoremail/$authoremail/g" \
    -e "s/r2d2_author/$author/g" \
    -e "s/r2d2_description/$description/g" \
    -e "s/r2d2_testlevel/$testlevel/g" \
    -e "s/r2d2_version/$version/g" \
    -e "s/r2d2_testsuitename/$testsuitename/g"\
    $makefile_template > $makefile_out
echo "makefile is done:      [$makefile_out]"

########################################
#    produce: PURPOSE                  #
########################################
sed -e "s/r2d2_authoremail/$authoremail/g" \
    -e "s/r2d2_author/$author/g" \
    -e "s/r2d2_description/$description/g" \
    -e "s/r2d2_testsuitename/$testsuitename/g"\
    $purpose_template > $purpose_out
echo "purpose file is done:  [$purpose_out]"

########################################
#    produce: testinfo.desc            #
########################################
sed -e "s/r2d2_authoremail/$authoremail/g" \
    -e "s/r2d2_author/$author/g" \
    -e "s/r2d2_description/$description/g" \
    -e "s/r2d2_testsuitename/$testsuitename/g"\
    $testinfo_template > $testinfo_out
echo "testinfo.desc is done: [$testinfo_out]"

########################################
#    produce: runtest.sh               #
########################################
sed -e "s/r2d2_authoremail/$authoremail/g" \
    -e "s/r2d2_author/$author/g" \
    -e "s/r2d2_testlevel/$testlevel/g"\
    -e "s/r2d2_testsuitename/$testsuitename/g"\
    $runtest_template > $runtest_out
echo " " >> $runtest_out
echo "# manifest:" >> $runtest_out
cat $manifest >> $runtest_out
echo "runtest.sh is done:    [$runtest_out]"

########################################
#    produce: t.$testsuitename.sh      #
########################################
r2d2pl=$RHTS/r2d2/r2d2.pl
echo $r2d2pl "$manifest" "$t_out" > /dev/null
$r2d2pl "$manifest" "$t_out" > /dev/null
echo "testcase file is done: [$t_out]"

echo "------------- end of r2d2 -----------"

