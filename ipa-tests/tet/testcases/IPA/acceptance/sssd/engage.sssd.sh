#ident "%W% %E%"
#
#	File name: run.sssd
#
#	This file contains the operations specific to the sssd tests.
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
# 07/15/09 | JGalipea     | Creation
# -----------------------------------------------------------------------------

# This function will set the default values for the variables needed.
#
sssd_default()
{
	if [ -z "$sssdRunIt" ]
	then
		sssdRunIt=n
	fi
}

# This function will ask the user for more information/choices if needed.
#
sssd_ask()
{

	sav_sssdRunIt=$sssdRunIt
	echo "    Execute sssd test suite [$sssdRunIt] ? \c"
	read rsp
	case $rsp in
		"")	sssdRunIt=$sav_sssdRunIt	;;
		y|Y)	
			sssdRunIt=y
			;;
		*)	sssdRunIt=n		;;
	esac

}

# This function will print the user's choices (aka variables)
#
sssd_print()
{
	echo "    Execute sssd test suite        : $sssdRunIt"
}

# This function will echo in shell's format the user's choices
# It is the calling function that will redirect the output to
# the saved config file.
#
sssd_save()
{
	echo "sssdRunIt=$sssdRunIt"
}

# This function will check that the test suite may be executed
# It may also perform some kind of pre-configuration of the machine.
# This function should "exit 1" if there is problem.
#
sssd_check()
{
	kgb=kgb
}

# This function will startup/initiate the test suite
#
sssd_startup()
{
:
}

# This function will run the test suite
#
sssd_run()
{
	if [ $sssdRunIt = n ]
	then
		return
	fi
	echo "sssd run..."
	echo "$TET_ROOT/$MainTccName -e -s $TET_ROOT/testcases/IPA/acceptance/sssd/tet_scen -x $TET_ROOT/testcases/IPA/tetexecpl.cfg $TET_ROOT/testcases/IPA/acceptance/sssd sssd"

	(
	$TET_ROOT/$MainTccName \
		-e -s $TET_ROOT/testcases/IPA/acceptance/sssd/tet_scen \
		-x $TET_ROOT/testcases/IPA/tetexecpl.cfg \
		$TET_ROOT/testcases/IPA/acceptance/sssd \
		sssd > $MainTmpDir/sssd.run.out 2>&1
	)&
	EngageTimer $! 1200 120 # wait 1200 sec before kill, then 1200 until kill -9
	echo ""
	echo "sssd run $MainTmpDir/sssd.run.out"
	echo ""
	cat $MainTmpDir/sssd.run.out
	echo ""
	main_analyze "sssd run" `grep "tcc: journal file is" $MainTmpDir/sssd.run.out | awk '{print $5}'` $MainTmpDir/sssd.run.out
	MainReportFiles="$MainReportFiles $MainTmpDir/sssd.run.out"

	Gfile="$TET_TMP_DIR/global_src_`uname -n`"
	rm -f $Gfile
}

# This function will cleanup after the test suite execution
#
sssd_cleanup()
{
:
}


#
# End of file
