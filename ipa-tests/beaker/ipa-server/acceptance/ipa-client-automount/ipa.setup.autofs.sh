#!/bin/bash

# include local libs
. ./lib.clientautomount.sh

usage(){
    echo " -------- "
    echo "| USAGE: |"
    echo "|  $0 -n <automount location name> -s <nfs server> -d <nfs shared directory> -m <map type: direct/indirect>  |"
    echo " ----------------------------------------------------------------------------------------------------------------------- "
}

id=$RANDOM

automountLocationName="yztest${id}"
maptype="indirect"
nfsServer="f17apple.yzhang.redhat.com"
nfsSharedDir="/share/pub"
autofsTopDir="/ipashare${id}"
autofsSubDir="ipapublic${id}"
autofsDir="$autofsTopDir/$autofsSubDir"

paramMsg="configure ipa automount using "
while getopts ":n:s:d:m:" opt ;do
    case $opt in
    n)
        automountLocationName=$OPTARG
        paramMsg="$paramMsg -n [$automountLocationName]"
        ;;
    s)
        nfsServer=$OPTARG
        paramMsg="$paramMsg -s [$nfsServer]"
        ;;
    d)
        nfsSharedDir=$OPTARG
        paramMsg="$paramMsg -d [$nfsSharedDir]"
        ;;
    m)
        maptype=$OPTARG
        paramMsg="$paramMsg -m [$maptype]"
        ;;
    \?)
        paramMsg="$0 :ERROR: invalid options: -$OPTARG "
        usage
        echo "$paramMsg" 
        exit
        ;;
    esac
done

if [ "$automountLocationName" != "" ] \
    && [ "$nfsServer" != "" ] \
    && [ "$nfsSharedDir" != "" ] \
    && [ "$autofsTopDir" != "" ] \
    && [ "$autofsSubDir" != "" ]
then
    echo "$paramMsg"
    if [ "$maptype" = "direct" ];then
        configAutofs_direct $automountLocationName $nfsServer $nfsSharedDir $autofsDir
    elif [ "$maptype" = "indirect" ];then
        configAutofs_indirect2 $automountLocationName $nfsServer $nfsSharedDir
    else
        echo "wrong map type, please use 'direct' or 'indirect'"
    fi
else
    usage
    echo "$paramMsg"
    exit
fi

