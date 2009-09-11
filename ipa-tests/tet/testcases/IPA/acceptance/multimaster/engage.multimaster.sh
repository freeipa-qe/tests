#ident "%W% %E%"
#
#	File name: run.multimaster
#
#	This file contains the operations specific to the multimaster tests.
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
# 05/15/08 | MGregg     | Creation
# -----------------------------------------------------------------------------

# This function will set the default values for the variables needed.
#
multimaster_default()
{
	if [ -z "$multimasterRunIt" ]
	then
		multimasterRunIt=n
	fi
}

# This function will ask the user for more information/choices if needed.
#
multimaster_ask()
{

	sav_multimasterRunIt=$multimasterRunIt
	echo "    Execute multimaster test suite [$multimasterRunIt] ? \c"
	read rsp
	case $rsp in
		"")	multimasterRunIt=$sav_multimasterRunIt	;;
		y|Y)	
			multimasterRunIt=y
			;;
		*)	multimasterRunIt=n		;;
	esac

}

# This function will print the user's choices (aka variables)
#
multimaster_print()
{
	echo "    Execute multimaster test suite        : $multimasterRunIt"
}

# This function will echo in shell's format the user's choices
# It is the calling function that will redirect the output to
# the saved config file.
#
multimaster_save()
{
	echo "multimasterRunIt=$multimasterRunIt"
}

# This function will check that the test suite may be executed
# It may also perform some kind of pre-configuration of the machine.
# This function should "exit 1" if there is problem.
#
multimaster_check()
{
	kgb=kgb
}

# This function will startup/initiate the test suite
#
multimaster_startup()
{
:
}

# This function will run the test suite
#
multimaster_run()
{
	if [ $multimasterRunIt = n ]
	then
		return
	fi
	echo "multimaster run..."
	echo "$TET_ROOT/$MainTccName -e -s $TET_ROOT/testcases/IPA/acceptance/multimaster/tet_scen -x $TET_ROOT/testcases/IPA/tetexecpl.cfg $TET_ROOT/testcases/IPA/acceptance/multimaster multimaster"

	$TET_ROOT/$MainTccName \
		-e -s $TET_ROOT/testcases/IPA/acceptance/multimaster/tet_scen \
		-x $TET_ROOT/testcases/IPA/tetexecpl.cfg \
		$TET_ROOT/testcases/IPA/acceptance/multimaster \
		multimaster > $MainTmpDir/multimaster.startup.out 2>&1
	echo ""
	echo "multimaster startup $MainTmpDir/multimaster.startup.out"
	echo ""
	cat $MainTmpDir/multimaster.startup.out
	echo ""
	main_analyze "multimaster startup" `grep "tcc: journal file is" $MainTmpDir/multimaster.startup.out | awk '{print $5}'` $MainTmpDir/multimaster.startup.out
	MainReportFiles="$MainReportFiles $MainTmpDir/multimaster.startup.out"

	Gfile="$TET_TMP_DIR/global_src_`uname -n`"
	rm -f $Gfile
}

# This function will cleanup after the test suite execution
#
multimaster_cleanup()
{
:
}


#
# End of file
