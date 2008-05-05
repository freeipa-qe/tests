[ ] // 
[ ] // \\ Console Local Configuration File //
[ ] //
[ ] // NOTES:
[ ] // Define the default installation information for a standalone console, admin server and
[ ] // directory. Current automation configuration requirements are that both the client
[ ] // and server are for identical platform OS versions.Eg. NT clients and NT servers.
[ ] // The framework however, can be modified to test NT clients against Unix Servers.
[ ] // The DefaultDirectoryState is defined as a standalone directory with only the
[ ] // default entries for NetscapeRoot and mcom.com.
[ ] //
[ ] // Modify this file after check out from the repository with the appropriate
[ ] // settings that match your local installation. Dont change any variable names but
[ ] // only the strings that are defined for them.
[ ] // 
[ ] // 
[ ] // 
[ ] //
[ ] // 
[ ] // Created by Sudesh Chandra on October 28th 1998
[ ] //
[+] // Revision History//
	[ ] // Date			By					Comments
	[ ] // --------------------------------------------------------------------------------
	[ ] // 10-28-98		Sudesh Chandra		Initial Creation
	[ ] //
	[ ] // 01-08-98     Sudesh Chandra      Add unixsrv and ntsrv UI change that
	[ ] //                                  needs these browsertypes to be defined
	[ ] //                                  in the 4test.inc file in the SILK install dir.
	[ ] //
	[ ] // 01-22-98     Sudesh Chandra      Secure Server tests modifications.	Set bSecureServer
	[ ] //                  	            to TRUE. The conf tests will check for server type
	[ ] //                                  and execute the rsh commands from NT to the remote host.
	[ ] //                                  The rsh daemon needs to be installed on each NT platform
	[ ] //                                  that the tests will be executed on. rshd is checked into
	[ ] //                                  CVS as the rshdnt.zip file.	Unix does not need the daemon.
	[ ] //09-08-99		Shirley Tan			Made the change for the console_frame.inc in order to test
	[ ] //									admin 4.1. See the detail at console_fram.inc revision history
	[ ] //						
[ ] //
[ ] //
[ ] // Set UnixServer to TRUE if the server under test is on the UNIX OS.
[ ] BOOLEAN bUnixServer = TRUE
[ ] //
[ ] // Is the Server a secure server?
[ ] BOOLEAN bSecureServer = FALSE
[ ] // Specify the token password for you secure server. This will be used when
[ ] // the server needs to be restarted.
[ ] STRING sTokenPassword = "netscape1"
[ ] //
[ ] //
[ ] //Domain information used during installation
[ ] STRING sDOMAIN1 = "mcom.com"
[ ] //
[ ] // Hostname for the admin server being tested
[ ] // STRING sHOST1 = "sudesh"
[ ] STRING sHOST1 = "juniper"
[ ] //
[ ] //Define the command line used to invoke the application
[ ] // ServerRoot installation of the Admin Server under test
[ ] STRING sNTServerRoot = "C:\Netscape\Server4\"
[ ] // STRING sUNIXServerRoot = "/export/home/schandra/41-0131" //OSF on deccms
[ ] // STRING sUNIXServerRoot = "/tmp/41-0225" //IRIX on foo3
[ ] // STRING sUNIXServerRoot = "/export/home/41-0115" // HPUX on mira
[ ] STRING sUNIXServerRoot = "/export/home/schandra/45-1207" // SOL on wedge
[ ] 
[ ] ntsrv STRING sNT_DIR = sNTServerRoot
[ ] ntsrv STRING sNT_CMD = "{sNTServerRoot}\RUN.bat"
[ ] STRING sUNIX_CMD = "{sUNIXServerRoot}/java/RUN"
[ ] //
[ ] //
[ ] // Enter the Number of the ServerGroup in which Admin Server Tests will be executed
[ ] INT iServerGroup = 1 // Uncomment if you are testing admin server in default server group for your sHOST1
[ ] // INT iServerGroup = 2 // Uncomment if you will test admin server in ServerGroup 2
[ ] // INT iServerGroup = 3 // Uncomment if you will test admin server in ServerGroup 3
[ ] // INT iServerGroup = 4 // Uncomment if you will test admin server in ServerGroup 4
[ ] //
[ ] //Is configuration directory server on the same host as the admin server sHOST1 that was set above?
[ ]  BOOLEAN bSLAPD_local = FALSE
[ ] // BOOLEAN bSLAPD_local = FALSE
[ ] //
[ ] //Name of the directory server instance for admin server configuration settings.
[ ] // STRING sSLAPD1 = "todiefor"
[ ] STRING sSLAPD1 = "Directory Server (wedge)"
[ ] //Name of the directory server host for admin server configuration settings.
[ ] STRING sSLAPDHOST1 = "wedge"
[ ] STRING sSLAPDServerGroup = "Server Group"
[ ] //
[ ] //
[ ] // Directory Server Port
[ ] STRING sConsole_LDAPPortNum = "400"
[ ] //
[ ] //Userid and Password for the Administrator
[ ] STRING sConsole_USERID = "admin"
[ ] STRING sConsole_PASSWORD = "admin"
[ ] //
[ ] // Admin Server PortValue used during the insatallation
[ ] STRING sConsole_PortNumber = "4444"
[ ] //
[ ] //
[ ] // Admin Server IPValue of the hostname where console is installed;
[ ] //  STRING sConsole_IPNumber = "208.12.63.151" //mira
[ ] //  STRING sConsole_IPNumber = "208.12.63.53" //ds9
[ ] // STRING sConsole_IPNumber = "208.12.63.49" //sudesh
[ ] // STRING sConsole_IPNumber = "208.12.63.151" //wedge
[ ] // STRING sConsole_IPNumber = "208.12.63.152" //aurora
[ ] // STRING sConsole_IPNumber = "208.12.63.75" //nikita
[ ] // STRING sConsole_IPNumber = "208.12.62.120" //jinxaix
[ ] // STRING sConsole_IPNumber = "208.12.63.207" //interlaken
[ ] // STRING sConsole_IPNumber = "208.12.62.116" //enright
[ ] //  STRING sConsole_IPNumber = "208.12.62.133" //deccms
[ ] // STRING sConsole_IPNumber = "208.12.63.77" //mambo
[ ] //STRING sConsole_IPNumber = "208.12.62.78" //yugo
[ ] //STRING sConsole_IPNumber = "208.12.62.43" //samurai
[ ]   STRING sConsole_IPNumber = "208.12.63.103" //tarannum
[ ] 
[ ] //
[ ] //Define the name of the results.txt file that you would like to log your test execution.
[ ] // msw STRING sResultFile = "{sNT_DIR}\results.txt"
[ ] STRING sResultFile = "d:\results.txt"
[ ] // motif STRING sResultFile = "{sUNIX_DIR}/results.txt"
[ ] //
[ ] //
[ ] //Define the Product and Application version under test
[ ] STRING MCConsoleAdminSeverVersion = "Console 4.5-bld-12-07"
[ ] //
[ ] //
[+] //public string sBaselineDir
	[ ] // Steps:
	[ ] //   1.)  Uncomment the appropriate line for your target platform.
	[ ] //	 2.) Sets the directory where machine specific baseline files reside.
	[ ] // Who		When			What
	[ ] // ---------------------------------------------------------------------
	[ ] 
[ ] public string sBaselineDir = "d:\Silk\mcc\"
[ ] // motif public string sBaselineDir = "{sUNIX_DIR}/baseline/"
[ ] //
[ ] STRING sADMINISTRATION_URL
[ ] public BOOLEAN  bOK = ConfSetAdminURL(bSecureServer,sHOST1,sConsole_PortNumber,sADMINISTRATION_URL)
[ ] //
[ ] // The include file below defines common functions and global variables for Console
[ ] // test execution. Checkout and modify this file only after code review and successfull
[ ] // execution of all tests on TIER 1 platforms.
[ ] use "console_fn.inc"
[ ] //
[ ] // The include file below defines the UI captions and strings for the MCC Admin Server
[ ] // The include file below should be checked out and modified only after a code review.
[ ] // Uncomment the appropriate inculde file for the language type of your choice
[ ] use "console_ui_str_en.inc"
[ ] //use "console_ui_str_ja.inc"
[ ] //use "console_ui_str_de.inc"
[ ] //use "console_ui_str_fr.inc"
[ ] //
[ ] //
[ ] //
[ ] // The include files below are for testdata strings and constants and by convention
[ ] // each test area and test data type will be self contained. If you are adding a new
[ ] // test data file then use the naming conventions below for the file names and also
[ ] // the conventions used to define test data variables. Refer to one of the
[ ] // test data files below for more information on the variable naming conventions.
[ ] //
[ ] // Uncomment the specific test files that reflect the type of testing to be executed.
[ ] //
[ ] use "console_tst_conf_str_7bit.inc"
[ ] //use "console_tst_conf_str_8bit.inc"
[ ] // use "console_tst_ug_str_7bit.inc"
[ ] use "console_tst_ug_str_8bit.inc"
[ ] // use "console_tst_tasks_str_7bit.inc"
[ ] // use "console_tst_tasks_str_8bit.inc"
[ ] // use "console_tst_topology_str_7bit.inc"
[ ] // use "console_tst_topology_str_8bit.inc"
[ ] // use "console_tst_cert_str_7bit.inc"
[ ] // use "console_tst_cert_str_8bit.inc"
