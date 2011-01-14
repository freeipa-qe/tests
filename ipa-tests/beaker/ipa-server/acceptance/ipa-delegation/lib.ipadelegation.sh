#!/bin/sh
# lib file for ipa delegation

getTestValue()
{
    local key=$1
    local valuefile=$2
    if [ -f $valuefile ];then
        value=`grep "$key" $valuefile | cut -d"=" -f2 | xargs echo`
    fi
    if [ -z "$value" ];then
        echo "";
    else
        echo "$value";
    fi
} #getTestValue
