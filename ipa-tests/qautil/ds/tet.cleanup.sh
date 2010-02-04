#!/bin/sh

curdir=`pwd`
cd / 
tet_base=$1
if [ -z $tet_base ];then
	tet_base=/dstet;
fi

if [ -d $tet_base ];then
	echo "using default tet_base=[$tet_base]"
else
	echo "no tet_base detected, usage : tet.cleanup.sh <tet_base>"
	exit
fi

echo "clean all tet result files"
find $tet_base -name "results" -type d | xargs rm -rfv

echo "clean all tet temp files"
rm -rfv $tet_base/testcases/DS/6.0/tet_tmp_dir/*

echo "clean all ds log files"
rm -rfv $tet_base/testcases/DS/6.0/ds_log_dir/*

cd $curdir
