#ident "%W% %E%"
#
#	File name: run.client
#
#	This file contains the operations specific to the client tests.
#	It is targetted to be included by the main script "run" and not be be 
#	used alone.
#
#	Replace the "xyz" by your name (e.g. "schema") and "Xyz" by your
#	name (e.g. "Schema").
#
#
#	History
# -----------------------------------------------------------------------------
# dd/mm/yy | Author	| Comments
# -----------------------------------------------------------------------------
# 10/2/08 | MGregg     | Creation
# -----------------------------------------------------------------------------

# This function will set the default values for the variables needed.
#
client_default()
{
	if [ -z "$clientRunIt" ]
	then
		clientRunIt=n
	fi
}

# This function will ask the user for more information/choices if needed.
#
client_ask()
{

	sav_clientRunIt=$clientRunIt
	echo "    Execute client test suite [$clientRunIt] ? \c"
	read rsp
	case $rsp in
		"")	clientRunIt=$sav_clientRunIt	;;
		y|Y)	
			clientRunIt=y
			;;
		*)	clientRunIt=n		;;
	esac

}

# This function will print the user's choices (aka variables)
#
client_print()
{
	echo "    Execute client test suite        : $clientRunIt"
}

# This function will echo in shell's format the user's choices
# It is the calling function that will redirect the output to
# the saved config file.
#
client_save()
{
	echo "clientRunIt=$clientRunIt"
}

# This function will check that the test suite may be executed
# It may also perform some kind of pre-configuration of the machine.
# This function should "exit 1" if there is problem.
#
client_check()
{
	kgb=kgb
}

# This function will startup/initiate the test suite
#
client_startup()
{
:
}

# This function will run the test suite
#
client_run()
{
	if [ $clientRunIt = n ]
	then
		return
	fi
	echo "client run..."
	echo "$TET_ROOT/$MainTccName -e -s $TET_ROOT/testcases/IPA/acceptance/client/tet_scen -x $TET_ROOT/testcases/IPA/tetexecpl.cfg $TET_ROOT/testcases/IPA/acceptance/client client"

	(
	$TET_ROOT/$MainTccName \
		-e -s $TET_ROOT/testcases/IPA/acceptance/client/tet_scen \
		-x $TET_ROOT/testcases/IPA/tetexecpl.cfg \
		$TET_ROOT/testcases/IPA/acceptance/client \
		client > $MainTmpDir/client.run.out 2>&1
	)&
	EngageTimer $! 1200 120 # wait 1200 sec before kill, then 1200 until kill -9
	echo ""
	echo "client run $MainTmpDir/client.run.out"
	echo ""
	cat $MainTmpDir/client.run.out
	echo ""
	main_analyze "client run" `grep "tcc: journal file is" $MainTmpDir/client.run.out | awk '{print $5}'` $MainTmpDir/client.run.out
	MainReportFiles="$MainReportFiles $MainTmpDir/client.run.out"

	Gfile="$TET_TMP_DIR/global_src_`uname -n`"
	rm -f $Gfile
}

# This function will cleanup after the test suite execution
#
client_cleanup()
{
:
}


#
# End of file
