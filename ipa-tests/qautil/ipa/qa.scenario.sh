#!/bin/sh

index=0
for client in "i386 1.0" "i386 1.1" "x86_64 1.0" "x86_64 1.1"
do
	for server in "i386 1.0" "x86_64 1.0"
	do
		for replica in "no_replica" "i386 1.0" "x86_64 1.0"
		do
			if [ "$replica" = "no_replica" ]
			then
				for result in "<font color=green>PASS</font> <font color=red>FAIL</font>"
                                do
                                        echo "|-"
                                        echo "|$index  || $client || $server || $replica || -- || $result"
                                        ((index=index + 1))
                                done  
			else
                        	for order in "update server first" "update replica first"
                        	do
                                	for result in "<font color=green>PASS</font> <font color=red>FAIL</font>"
                                	do
                                        	echo "|-"
                                        	echo "|$index  || $client || $server || $replica || $order || $result"
                                        	((index=index + 1))
                                	done    
                        	done
			fi
		done
	done
done

