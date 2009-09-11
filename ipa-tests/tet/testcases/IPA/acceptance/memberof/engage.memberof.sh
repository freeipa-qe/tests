#ident "%W% %E%"
#
#	File name: run.memberof
#
#	This file contains the operations specific to the memberof tests.
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
memberof_default()
{
	if [ -z "$memberofRunIt" ]
	then
		memberofRunIt=n
	fi
}

# This function will ask the user for more information/choices if needed.
#
memberof_ask()
{

	sav_memberofRunIt=$memberofRunIt
	echo "    Execute memberof test suite [$memberofRunIt] ? \c"
	read rsp
	case $rsp in
		"")	memberofRunIt=$sav_memberofRunIt	;;
		y|Y)	
			memberofRunIt=y
			;;
		*)	memberofRunIt=n		;;
	esac

}

# This function will print the user's choices (aka variables)
#
memberof_print()
{
	echo "    Execute memberof test suite        : $memberofRunIt"
}

# This function will echo in shell's format the user's choices
# It is the calling function that will redirect the output to
# the saved config file.
#
memberof_save()
{
	echo "memberofRunIt=$memberofRunIt"
}

# This function will check that the test suite may be executed
# It may also perform some kind of pre-configuration of the machine.
# This function should "exit 1" if there is problem.
#
memberof_check()
{
	kgb=kgb
}

# This function will startup/initiate the test suite
#
memberof_startup()
{
:
}

# This function will run the test suite
#
memberof_run()
{
	if [ $memberofRunIt = n ]
	then
		return
	fi
	echo "memberof run..."
	echo "$TET_ROOT/$MainTccName -e -s $TET_ROOT/testcases/IPA/acceptance/memberof/tet_scen -x $TET_ROOT/testcases/IPA/tetexecpl.cfg $TET_ROOT/testcases/IPA/acceptance/memberof memberof"

	(
	$TET_ROOT/$MainTccName \
		-e -s $TET_ROOT/testcases/IPA/acceptance/memberof/tet_scen \
		-x $TET_ROOT/testcases/IPA/tetexecpl.cfg \
		$TET_ROOT/testcases/IPA/acceptance/memberof \
		memberof > $MainTmpDir/memberof.startup.out 2>&1
	)&
	EngageTimer $! 2100 120 # wait 2100 sec before kill, then 120 until kill -9
	echo ""
	echo "memberof startup $MainTmpDir/memberof.startup.out"
	echo ""
	cat $MainTmpDir/memberof.startup.out
	echo ""
	main_analyze "memberof startup" `grep "tcc: journal file is" $MainTmpDir/memberof.startup.out | awk '{print $5}'` $MainTmpDir/memberof.startup.out
	MainReportFiles="$MainReportFiles $MainTmpDir/memberof.startup.out"

	Gfile="$TET_TMP_DIR/global_src_`uname -n`"
	rm -f $Gfile
}

# This function will cleanup after the test suite execution
#
memberof_cleanup()
{
:
}


#
# End of file
