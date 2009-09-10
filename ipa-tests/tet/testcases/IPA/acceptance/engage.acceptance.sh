#!/bin/sh
#
# File Name: engage.acceptan
#
######### Include directories ############################################
. $mainRunBaseDir/acceptance/quickinstall/engage.quickinstall
. $mainRunBaseDir/acceptance/memberof/engage.memberof
. $mainRunBaseDir/acceptance/multimaster/engage.multimaster
. $mainRunBaseDir/acceptance/quickuninstall/engage.quickuninstall
. $mainRunBaseDir/acceptance/cli/engage.cli
. $mainRunBaseDir/acceptance/client/engage.client
. $mainRunBaseDir/acceptance/pwpolicy/engage.pwpolicy
. $mainRunBaseDir/acceptance/sssd/engage.sssd
. $mainRunBaseDir/sample/engage.sample


#####################################################

acceptance_default()
{
#	dsmlgw_default
	quickinstall_default
	memberof_default
	multimaster_default
	cli_default
	client_default
	pwpolicy_default
	sssd_default
	quickuninstall_default
	sample_default
}

# This function will ask the user for more information/choices if needed.
#
acceptance_ask()
{
		quickinstall_ask
		memberof_ask
		multimaster_ask
		cli_ask
		client_ask
		pwpolicy_ask
		sssd_ask
		quickuninstall_ask
		sample_ask
}

# This function will print the user's choices (aka variables)
#
acceptance_print()
{
		quickinstall_print
		memberof_print
		multimaster_print
		cli_print
		client_print
		pwpolicy_print
		sssd_print
		quickuninstall_print
		sample_print
}

# This function will echo in shell's format the user's choices
# It is the calling function that will redirect the output to
# the saved config file.
#
acceptance_save()
{

	quickinstall_save
	sample_save
	memberof_save
	multimaster_save
	cli_save
	client_save
	pwpolicy_save
	sssd_save
        # quickinstall needs to be last
        quickuninstall_save 
}

# This function will check that the test suite may be executed
# It may also perform some kind of pre-configuration of the machine.
# This function should "exit 1" if there is problem.
#
acceptance_check()
{

		quickinstall_check
		memberof_check
		multimaster_check
		cli_check
		client_check
		pwpolicy_check
		sssd_check
		quickuninstall_check
		sample_check
}

# This function will run the test suite
#
acceptance_run()
{
echo "Starting Acceptance Tests........."

TET_SUITE_ROOT=$mainRunBaseDir/sample; export TET_SUITE_ROOT
if [ $MainRunStartup = y ] ; then sample_startup ; fi
if [ $MainRunTests = y ]   ; then sample_run     ; fi
if [ $MainRunCleanup = y ] ; then sample_cleanup ; fi

TET_SUITE_ROOT=$mainRunBaseDir/acceptance; export TET_SUITE_ROOT
if [ $MainRunStartup = y ] ; then quickinstall_startup ; fi
if [ $MainRunTests = y ] ; then quickinstall_run ; fi
if [ $MainRunCleanup = y ] ; then quickinstall_cleanup ; fi

TET_SUITE_ROOT=$mainRunBaseDir/memberof; export TET_SUITE_ROOT
if [ $MainRunStartup = y ] ; then memberof_startup ; fi
if [ $MainRunTests = y ]   ; then memberof_run     ; fi
if [ $MainRunCleanup = y ] ; then memberof_cleanup ; fi

TET_SUITE_ROOT=$mainRunBaseDir/cli; export TET_SUITE_ROOT
if [ $MainRunStartup = y ] ; then cli_startup ; fi
if [ $MainRunTests = y ]   ; then cli_run     ; fi
if [ $MainRunCleanup = y ] ; then cli_cleanup ; fi

TET_SUITE_ROOT=$mainRunBaseDir/client; export TET_SUITE_ROOT
if [ $MainRunStartup = y ] ; then client_startup ; fi
if [ $MainRunTests = y ]   ; then client_run     ; fi
if [ $MainRunCleanup = y ] ; then client_cleanup ; fi

TET_SUITE_ROOT=$mainRunBaseDir/multimaster; export TET_SUITE_ROOT
if [ $MainRunStartup = y ] ; then multimaster_startup ; fi
if [ $MainRunTests = y ]   ; then multimaster_run     ; fi
if [ $MainRunCleanup = y ] ; then multimaster_cleanup ; fi

TET_SUITE_ROOT=$mainRunBaseDir/pwpolicy; export TET_SUITE_ROOT
if [ $MainRunStartup = y ] ; then pwpolicy_startup ; fi
if [ $MainRunTests = y ] ; then pwpolicy_run ; fi
if [ $MainRunCleanup = y ] ; then pwpolicy_cleanup ; fi

TET_SUITE_ROOT=$mainRunBaseDir/sssd; export TET_SUITE_ROOT
if [ $MainRunStartup = y ] ; then sssd_startup ; fi
if [ $MainRunTests = y ] ; then sssd_run ; fi
if [ $MainRunCleanup = y ] ; then sssd_cleanup ; fi

TET_SUITE_ROOT=$mainRunBaseDir/acceptance; export TET_SUITE_ROOT
if [ $MainRunStartup = y ] ; then quickuninstall_startup ; fi
if [ $MainRunTests = y ] ; then quickuninstall_run ; fi
if [ $MainRunCleanup = y ] ; then quickuninstall_cleanup ; fi


# uninstall MUST be last
#TET_SUITE_ROOT=$mainRunBaseDir/acceptance; export TET_SUITE_ROOT
#if [ $MainRunStartup = y ] ; then quickuninstall_startup ; fi
#if [ $MainRunTests = y ] ; then quickuninstall_run ; fi

}



#
# End of file
