#ident "%W% %E%"
#
#	File name: run.quickuninstall
#
#	This file contains the operations specific to the quickuninstall tests.
#	It is targetted to be included by the main script "run" and not be be 
#	used alone.
#
#	Replace the "xyz" by your name (e.g. "schema") and "Xyz" by your
#	name (e.g. "Schema").
#
#	Created by Jean-Luc SCHWING - SUN Microsystems :
#		Thu Jul  1 14:47:28 PDT 1999
#
#	History
# -----------------------------------------------------------------------------
# dd/mm/yy | Author	| Comments
# -----------------------------------------------------------------------------
# 01/07/99 | JL SCHWING	| Creation.
# -----------------------------------------------------------------------------

# This function will set the default values for the variables needed.
#
quickuninstall_default()
{
	if [ -z "$QuickUninstallRunIt" ]
	then
		QuickUninstallRunIt=n
	fi
}

# This function will ask the user for more information/choices if needed.
#
quickuninstall_ask()
{
	sav_QuickUninstallRunIt=$QuickUninstallRunIt
	echo "    Execute quickuninstall test suite [$QuickUninstallRunIt] ? \c"
	read rsp
	case $rsp in
		"")	QuickUninstallRunIt=$sav_QuickUninstallRunIt	;;
		y|Y)	QuickUninstallRunIt=y ;;
		*)	QuickUninstallRunIt=n		;;
	esac

}

# This function will print the user's choices (aka variables)
#
quickuninstall_print()
{
	echo "    Execute quickuninstall test suite        : $QuickUninstallRunIt"
}

# This function will echo in shell's format the user's choices
# It is the calling function that will redirect the output to
# the saved config file.
#
quickuninstall_save()
{
	echo "QuickUninstallRunIt=$QuickUninstallRunIt"
}

# This function will check that the test suite may be executed
# It may also perform some kind of pre-configuration of the machine.
# This function should "exit 1" if there is problem.
#
quickuninstall_check()
{
	kgb=kgb
}

# This function will startup/initiate the test suite
#
quickuninstall_startup()
{
:
}

# This function will run the test suite
#
quickuninstall_run()
{
	if [ $QuickUninstallRunIt = n ]
	then
		return
	fi
	echo "QuickUninstall run..."
	$TET_ROOT/$MainTccName \
		-e -s $TET_ROOT/testcases/IPA/acceptance/quickuninstall/tet_scen.sh \
		-x $TET_ROOT/testcases/IPA/tetexecpl.cfg \
		$TET_ROOT/testcases/IPA/acceptance/quickuninstall \
		uninstall > $MainTmpDir/quickuninstall.cleanup.out 2>&1
	main_analyze "QuickUninstall cleanup" `grep "tcc: journal file is" $MainTmpDir/quickuninstall.cleanup.out | awk '{print $5}'` $MainTmpDir/quickuninstall.cleanup.out
	MainReportFiles="$MainReportFiles $MainTmpDir/quickuninstall.cleanup.out"
}

# This function will cleanup after the test suite execution
#
quickuninstall_cleanup()
{
:
}


#
# End of file
