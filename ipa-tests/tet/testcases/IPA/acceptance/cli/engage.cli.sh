#ident "%W% %E%"
#
#	File name: run.cli
#
#	This file contains the operations specific to the cli tests.
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
cli_default()
{
	if [ -z "$cliRunIt" ]
	then
		cliRunIt=n
	fi
}

# This function will ask the user for more information/choices if needed.
#
cli_ask()
{

	sav_cliRunIt=$cliRunIt
	echo "    Execute cli test suite [$cliRunIt] ? \c"
	read rsp
	case $rsp in
		"")	cliRunIt=$sav_cliRunIt	;;
		y|Y)	
			cliRunIt=y
			;;
		*)	cliRunIt=n		;;
	esac

}

# This function will print the user's choices (aka variables)
#
cli_print()
{
	echo "    Execute cli test suite        : $cliRunIt"
}

# This function will echo in shell's format the user's choices
# It is the calling function that will redirect the output to
# the saved config file.
#
cli_save()
{
	echo "cliRunIt=$cliRunIt"
}

# This function will check that the test suite may be executed
# It may also perform some kind of pre-configuration of the machine.
# This function should "exit 1" if there is problem.
#
cli_check()
{
	kgb=kgb
}

# This function will startup/initiate the test suite
#
cli_startup()
{
:
}

# This function will run the test suite
#
cli_run()
{
	if [ $cliRunIt = n ]
	then
		return
	fi
	echo "cli run..."
	echo "$TET_ROOT/$MainTccName -e -s $TET_ROOT/testcases/IPA/acceptance/cli/tet_scen.sh -x $TET_ROOT/testcases/IPA/tetexecpl.cfg $TET_ROOT/testcases/IPA/acceptance/cli cli"

	(
	$TET_ROOT/$MainTccName \
		-e -s $TET_ROOT/testcases/IPA/acceptance/cli/tet_scen.sh \
		-x $TET_ROOT/testcases/IPA/tetexecpl.cfg \
		$TET_ROOT/testcases/IPA/acceptance/cli \
		cli > $MainTmpDir/cli.run.out 2>&1
	)&
	EngageTimer $! 1200 120 # wait 1200 sec before kill, then 1200 until kill -9
	echo ""
	echo "cli run $MainTmpDir/cli.run.out"
	echo ""
	cat $MainTmpDir/cli.run.out
	echo ""
	main_analyze "cli run" `grep "tcc: journal file is" $MainTmpDir/cli.run.out | awk '{print $5}'` $MainTmpDir/cli.run.out
	MainReportFiles="$MainReportFiles $MainTmpDir/cli.run.out"

	Gfile="$TET_TMP_DIR/global_src_`uname -n`"
	rm -f $Gfile
}

# This function will cleanup after the test suite execution
#
cli_cleanup()
{
:
}


#
# End of file
