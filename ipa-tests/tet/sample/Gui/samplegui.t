[ ] //
[ ] // Netscape Silk Acceptance Tests for Console Admin Server
[ ] // Created by Sudesh Chandra on December 2nd 1998
[ ] // 
[ ] // use "console_frame.inc"
[ ] // use "console_local_cfg.inc"
[ ] //
[+] // Revision History//
	[ ] // Date			By					Comments
	[ ] // --------------------------------------------------------------------------------
	[ ] // 12-2-98		Sudesh Chandra		Initial set of 13 acceptance tests
	[ ] // 12-9-98		Andreas Becker   	Added acceptance test 14
	[ ] // 									
	[ ] //
[ ] // 
[ ] //Tests the Login Window Invoke
[+] // testcase StartApp() appstate none
	[ ] // Console.Invoke()
	[ ] // Console.SetActive()
	[ ] // Console.Close()
	[ ] // 
[+] // testcase StartApp2() appstate none
	[ ] // Console.Invoke2()
	[ ] // Console.SetActive()
	[ ] // Console.Close()
	[ ] // 
[ ] //
[-] testcase GuiStartTest()
	[ ] AGPrint ("GUI START TEST")
	[ ] fStartTest()
[-] testcase GuiEndTest()
	[ ] AGPrint ("GUI END TEST")
	[ ] fEndTest()
	[ ] //
[ ] //Tests the Menu and Menu Items and Recovery to DefaultBaseState
[-] testcase ConsoleMenu ()
		[ ] // Console.SetActive ()
		[ ] Console.Console.CreateAdministrationDomain.Pick ()
		[ ] // CreateNewAdministrationDoma.SetActive ()
		[ ] CreateNewAdministrationDoma.DomainName.SetPosition (1, 1)
		[ ] CreateNewAdministrationDoma.DomainName.SetText ("test")
		[ ] CreateNewAdministrationDoma.Cancel.Click ()
		[ ] Console.Console.AddPre40Server.Pick ()
		[ ] AddPre40Servers.Cancel.Click()
		[ ] // Console.Close ()
[ ] //
[ ] //Search for MIRA in Users and Groups
[+] testcase SearchUG ()
		[ ] Console.SetActive ()
		[ ] Console.Tabs.Select ("Users and Groups")
		[ ] Console.Tabs.JavaJFCTextField("Search Users, Groups, and Organizational Units for:").SetPosition (1, 5)
		[ ] Console.Tabs.JavaJFCTextField("Search Users, Groups, and Organizational Units for:").SetText ("MIRA")
		[ ] // Console.Tabs.JavaJFCPushButton("Search").TypeKeys ("peter")
		[ ] Console.Tabs.JavaJFCPushButton("Search").Click ()
		[ ] Sleep (1)
		[+] Console.Tabs.JavaJFCTable("Search Results:").VerifyProperties ({...})
			[ ] "" 
			[+] {...}
				[ ] {"Contents",           {"Total objects found: 0"}}
				[ ] {"MultiSelText",       {}}
		[ ] Console.SetActive ()
		[ ] Console.Tabs.Select ("Console")
		[ ] Sleep(2)
[ ] //
[ ] //Get the default topology printed in the res file
[+] testcase Test2 ()
	[ ] LIST OF STRING lsContents = Console.Tabs.Hosts.GetContents()
	[ ] print (lsContents)
[ ] //
[ ] // Expand and Collapse Domain Tests
[+] testcase Test3 ()
		[ ] Console.SetActive ()
		[ ] Console.Tabs.Hosts.Expand (sDOMAIN1)
		[ ] Console.Tabs.Hosts.Expand (sHOST1 + "." + sDOMAIN1)
		[+] switch (iServerGroup)
			[+] case 1
				[ ] Console.Tabs.Hosts.Expand (sConsole_ServerGroup)
			[+] case 2
				[ ] Console.Tabs.Hosts.Expand (sConsole_ServerGroup2)
			[+] case 3
				[ ] Console.Tabs.Hosts.Expand (sConsole_ServerGroup3)
			[ ] 
		[ ] 
		[ ] Console.Tabs.Hosts.Collapse (sDOMAIN1)
		[ ] 
[ ] //
[ ] // Pop up the Console menu and dismiss it
[+] testcase Test4 ()
		[ ] Console.SetActive ()
		[ ] Console.Edit.Preferences.Pick ()
		[ ] Preferences.SetActive ()
		[ ] Preferences.Tabs.Clear.Click ()
		[ ] Preferences.Tabs.SaveNow.Click ()
		[ ] Preferences.OK.Click ()
[ ] //
[ ] // Select Users and Groups TAB and dismiss it
[+] testcase Test5 ()
	[ ] Console.SetActive()
	[ ] Console.Tabs.Select ("Users and Groups")
	[ ] Console.Tabs.Select ("Console")
	[ ] Console.Tabs.Select ("Users and Groups")
	[ ] Console.Tabs.Select ("Console")
[ ] //
[ ] //Tests the tree view, expanding controls and double selecting the admin server and then restarting it.
[+] testcase Test6 () appstate Console_Tasks
	[+] if (bSecureServer)
		[ ] AGPrint("CONF-log: Restarting the SECURE server now ....")
		[ ] bOK = !ConfRemoteRestartServer (sHOST1)
	[+] else
		[ ] AGPrint("CONF-log: Restarting the server now ....")
		[ ] AdministrationServerConsol.AdministrationServer1.RestartServerButton2.Click ()
		[ ] AdministrationServerConsol.JavaDialogBox("Restart Server").JavaJFCTextField("#1").Exists()
		[-] AdministrationServerConsol.JavaDialogBox("Restart Server").JavaJFCTextField("#1").VerifyProperties ({...})
			[ ] ""
			[-] {...}
				[-] {"MultiText",            [LIST OF STRING] {...}}
					[ ] ""
					[ ] ""
					[ ] "Issuing restart request ..."
					[ ] "Restart request accepted by the server."
					[ ] "Waiting for the server to restart ..."
					[ ] ""
					[ ] // "The Administration Server has been stopped!"
					[ ] // "Waiting for the server to start ..."
					[ ] // "**"
					[ ] // "The Administration Server has been restarted!"
					[ ] // ""
		[ ] AdministrationServerConsol.JavaDialogBox("Restart Server").JavaJFCPushButton("Close").Click ()
		[ ] 
		[ ] // AdministrationServerConsol.JavaDialogBox("Restart Server").SetActive ()
		[ ] // AdministrationServerConsol.JavaDialogBox("Restart Server").JavaJFCPushButton("Close").Click ()
		[ ] AdministrationServerConsol.SetActive ()
		[ ] AdministrationServerConsol.Close ()
		[ ] 
		[ ] 
[ ] //
[ ] //Tests the Open pushbutton for launch of the administration server console window
[+] testcase Test7 ()
		[ ] Console.Tabs.Hosts.Expand (sDOMAIN1)
		[ ] Console.Tabs.Hosts.Expand ("{sDOMAIN1}/{sHOST1}.{sDOMAIN1}")
		[+] switch (iServerGroup)
			[-] case 1
				[ ] // INTEGER iINDEX1 = Console.Tabs.Hosts.FindItem ("{sDOMAIN1}/{sHOST1}.{sDOMAIN1}/{sConsole_ServerGroup}")
				[ ] Console.Tabs.Hosts.Expand ("{sDOMAIN1}/{sHOST1}.{sDOMAIN1}/{sConsole_ServerGroup}")
				[ ] INTEGER iSrvIndex1 = Console.Tabs.Hosts.FindItem ("{sDOMAIN1}/{sHOST1}.{sDOMAIN1}/{sConsole_ServerGroup}/{sConsole_AdministrationServer}")
				[ ] Console.Tabs.Hosts.DoubleSelect (iSrvIndex1)
			[-] case 2
				[ ] Console.Tabs.Hosts.Expand ("{sDOMAIN1}/{sHOST1}.{sDOMAIN1}/{sConsole_ServerGroup2}")
				[ ] INTEGER iSrvIndex2 = Console.Tabs.Hosts.FindItem ("{sDOMAIN1}/{sHOST1}.{sDOMAIN1}/{sConsole_ServerGroup2}/{sConsole_AdministrationServer}")
				[ ] Console.Tabs.Hosts.DoubleSelect (iSrvIndex2)
			[-] case 3
				[ ] Console.Tabs.Hosts.Expand ("{sDOMAIN1}/{sHOST1}.{sDOMAIN1}/{sConsole_ServerGroup3}")
				[ ] INTEGER iSrvIndex3 = Console.Tabs.Hosts.FindItem ("{sDOMAIN1}/{sHOST1}.{sDOMAIN1}/{sConsole_ServerGroup3}/{sConsole_AdministrationServer}")
				[ ] Console.Tabs.Hosts.DoubleSelect (iSrvIndex3)
			[-] case 4
				[ ] Console.Tabs.Hosts.Expand ("{sDOMAIN1}/{sHOST1}.{sDOMAIN1}/{sConsole_ServerGroup4}")
				[ ] INTEGER iSrvIndex4 = Console.Tabs.Hosts.FindItem ("{sDOMAIN1}/{sHOST1}.{sDOMAIN1}/{sConsole_ServerGroup4}/{sConsole_AdministrationServer}")
				[ ] Console.Tabs.Hosts.DoubleSelect (iSrvIndex4)
			[ ] 
			[ ] //
		[ ] 
		[ ] Console.Tabs.JavaJFCPushButton("Open").Click ()
		[ ] Sleep (5)
		[ ] AdministrationServerConsol.Close ()
		[ ] Console.Tabs.Hosts.Collapse ("mcom.com")
[ ] //
[ ] //Add a 8bit entry into the User and Groups directory and then search for that entry
[+] testcase Test8 ()
		[ ] Console.SetActive ()
		[ ] Console.Tabs.Select ("Users and Groups")
		[ ] Console.Tabs.JavaJFCPushButton("Create").Click ()
		[ ] SelectOrganizationalUnit.DirectorySubtree.Select("People")
		[ ] SelectOrganizationalUnit.OK.Click()
		[ ] JavaDialogBox1.SetActive ()
		[ ] JavaDialogBox1.JavaJFCPageList("Create User").JavaJFCTextField("? First Name:").SetPosition (1, 1)
		[ ] JavaDialogBox1.JavaJFCPageList("Create User").JavaJFCTextField("? First Name:").SetPosition (1, 1)
		[ ] JavaDialogBox1.JavaJFCPageList("Create User").JavaJFCTextField("? First Name:").SetText ("Ändréaß")
		[ ] JavaDialogBox1.JavaJFCPageList("Create User").JavaJFCTextField("? Last Name:").SetPosition (1, 7)
		[ ] JavaDialogBox1.JavaJFCPageList("Create User").JavaJFCTextField("? Last Name:").SetText ("Bäckür")
		[ ] JavaDialogBox1.JavaJFCPageList("Create User").JavaJFCTextField("? User ID:").SetText ("abecker")
		[ ] JavaDialogBox1.OK.Click ()
		[ ] 
		[ ] string sIntl
		[ ] Console.SetActive ()
		[ ] Console.Tabs.Select ("Users and Groups")
		[ ] Console.Tabs.JavaJFCTextField("Search Users, Groups, and Organizational Units for:").SetPosition (1, 5)
		[ ] Console.Tabs.JavaJFCTextField("Search Users, Groups, and Organizational Units for:").SetText ("Ändréaß")
		[ ] sIntl = Console.Tabs.JavaJFCTextField("Search Users, Groups, and Organizational Units for:").GetText ()
		[-] if sIntl == "Ändréaß"
			[ ] print(sIntl + "Passed")
		[-] else
			[ ] print(sIntl + "Failed")
		[ ] print (Console.Tabs.JavaJFCTable("Search Results:").GetContents() )
		[ ] // Console.Tabs.JavaJFCPushButton("Search").TypeKeys ("Ändréaß")
		[ ] Console.Tabs.JavaJFCPushButton("Search").Click ()
		[ ] Sleep (1)
		[+] UGTab.SearchResult.VerifyProperties ({...})
			[ ] ""
			[-] {...}
				[-] {"MultiSelText",         [LIST OF STRING] {...}}
					[ ] "Ändréaß Bäckür"
					[ ] "abecker"
					[ ] ""
					[ ] ""
		[ ] UGTab.Delete.Click()
		[ ] ConfirmDelete.Yes.Click()
		[ ] 
		[ ] Console.SetActive ()
		[ ] Console.Tabs.Select ("Console")
	[ ] 
[ ] //
[ ] //Tests the advanced search and verifies the results returned in the JFC table
[-] testcase Test9 ()
		[ ] Console.SetActive ()
		[ ] Console.Tabs.Select ("Users and Groups")
		[ ] Console.Tabs.JavaJFCPushButton("Advanced").Click ()
		[ ] AdvancedSearch.SearchFor.SetText("directory")
		[ ] AdvancedSearch.Search.Click()
		[+] UGTab.SearchResult.VerifyProperties ({...})
			[ ] ""
			[+] {...}
				[-] {"MultiSelText",         [LIST OF STRING] {...}}
					[ ] "Directory Administrators"
					[ ] ""
					[ ] ""
					[ ] ""
		[ ] AdvancedSearch.Close.Click()
		[ ] Console.Tabs.Select ("Console")
[ ] //
[ ] //Tests the Console-View-MenuItem Custom View Configuration
[+] testcase Test10 ()
		[ ] Console.SetActive ()
		[ ] Console.Tabs.Select ("Console")
		[ ] Console.View.CustomViewConfig.Pick ()
		[ ] CustomViewConfiguration.SetActive ()
		[ ] CustomViewConfiguration.Close.Click ()
		[ ] Console.SetActive ()
[ ] //
[ ] //Add Console hello view and then back to default view
[+] testcase Test11 ()
	[ ] Console.SetActive()
	[ ] Console.Tabs.Select ("Console")
	[ ] Console.View.CustomViewConfig.Pick ()
	[ ] CustomViewConfiguration.SetActive ()
	[ ] CustomViewConfiguration.New.Click ()
	[ ] NewView.ViewName.SetText("Hello")
	[ ] NewView.OK.Click()
	[ ] CustomViewConfiguration.Close.Click ()
	[ ] 
	[ ] Console.Tabs.Views.Select ("Hello")
	[ ] Console.Tabs.Views.Select ("Default View")
[ ] //
[ ] //Bring up the second level tabs and verify view for all Right Tabs
[+] testcase Test12 () appstate Console_Tasks
	[ ] AdministrationServerConsol.AdministrationServer1.Select ("Configuration")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.RightTabs.Select ("Configuration DS")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.Select ("Tasks")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.Select ("Configuration")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.RightTabs.Select ("Access")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.Select ("Tasks")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.Select ("Configuration")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.RightTabs.Select ("User DS")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.Select ("Tasks")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.Select ("Configuration")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.RightTabs.Select ("Encryption")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.AdministrationServer1.RightTabs.Select ("Network")
	[ ] sleep(2)
	[ ] AdministrationServerConsol.Close()
	[ ] 
[ ] //
[ ] //Test the JFCPopUp menu in restarting the server in Admin Server Console window
[+] testcase Test13 () appstate Console_Cfg
	[ ] //
	[ ] AGPrint("CONF-log: Add IP Address allowed, Save, Edit and Remove")
	[ ] AdministrationServerConsol.AdministrationServer1.RightTabs.JavaJFCComboBox("#1").Select("#2")
	[ ] AGPrint("CONF-log: Allow IP addresses selected")
	[ ] //
	[ ] AddIPAddress.Invoke() 
	[+] if ! ( AdministrationServerConsol.JavaDialogBox(sConsole_AddIPAddress).Exists() )
		[ ] AGLogError ( "CONF-err: Add Host Name Dialog Box Not Found" )
		[ ] // return
	[ ] AddIPAddress.IPAddress.SetText (sTST_CONF_HostIP) 
	[ ] AGPrint("CONF-log: Adding IP address allowed {sTST_CONF_HostIP}")
	[+] AddIPAddress.JavaJFCPushButton(sConsole_OK).Click ()
		[ ] // AdministrationServerConsol.AdministrationServer1.RightTabs.Remove.Click()
		[ ] // AGPrint ("Add HostName Value = {sTST_CONF_Hosts} was not correctly saved")
		[ ] // AGPrint ("Add HostName Value = {sTST_CONF_Hosts} was correctly saved")
	[ ] AGPrint ("CONF-log: Add IP Address Value = {sTST_CONF_HostIP} was correctly saved")
	[ ] AGPrint("CONF-log: Restart the server and verify that the new host name allowed is listed")
	[ ] //
	[ ] //
	[ ] // AdministrationServerConsol.SetActive ()
	[ ] AdministrationServerConsol.AdministrationServer1.Save.Click()
	[ ] // Print(SaveDialogBox.JavaJFCTextField("#1").GetText())
	[ ] // Print(Console.GetChildren())
	[ ] 
	[ ] // WINDOW wWindow = null
	[ ] // AGGetWindow ("", wWindow )
	[ ] // wWindow.JavaJFCPushButton("OK").Click()
	[ ] 
	[ ] // SaveDialogBox.OK.Click()
	[ ] AdministrationServerConsol.JavaDialogBox("#1").JavaJFCPushButton(sConsole_OK).Click()
	[ ] 
	[ ] AdministrationServerConsol.AdministrationServer1.Select(sConsole_Tasks)
	[ ] // AdministrationServerConsol.SetActive ()
	[ ] // Agent.SetOption (OPT_MOUSE_DELAY, 0.5)
	[ ] // STRING sBUF
	[ ] sBUFFER = AdministrationServerConsol.AdministrationServer1.RestartServerText.GetText ()
	[+] if ( sBUFFER == "Restart Server")
		[ ] AGPrint("CONF-log: Restarting the server now ....")
		[ ] 
	[ ] AdministrationServerConsol.AdministrationServer1.RestartServerButton2.SetFocus ()
	[ ] AdministrationServerConsol.AdministrationServer1.RestartServerText.Click (2, 46, 11)
	[ ] AdministrationServerConsol.JavaJFCPopupMenu("JPopupMenu").Click() //Works on NT but not with the SilkBean
	[ ] // use the workaround below.
	[ ] //
	[ ] // RECT rect1 = AdministrationServerConsol.AdministrationServer1.getRect()
	[ ] // RECT rect2 = AdministrationServerConsol.AdministrationServer1.RestartServerButton2.getRect()
	[ ] // AdministrationServerConsol.PressMouse(3, 356, rect1.yPos + rect2.yPos + 10)
	[ ] // Agent.FlushEvents()
	[ ] // AdministrationServerConsol.AdministrationServer1.RestartServerButton2.Click ()
	[ ] // AdministrationServerConsol.AdministrationServer1.RestartServerText.Click (2, 46, 11)
	[ ] // AdministrationServerConsol.JavaJFCPopupMenu("JPopupMenu").JavaJFCMenuItem("Open").Pick()
	[ ] 
	[ ] // AdministrationServerConsol.JavaDialogBox("Restart Server").SetActive ()
	[+] AdministrationServerConsol.JavaDialogBox("Restart Server").JavaJFCTextField("#1").VerifyProperties ({...})
		[ ] ""
		[-] {...}
			[-] {"MultiText",            [LIST OF STRING] {...}}
				[ ] ""
				[ ] ""
				[ ] sConsole_IRR
				[ ] sConsole_RRA
				[ ] sConsole_WSR
				[ ] ""
				[ ] // "The Administration Server has been stopped!"
				[ ] // "Waiting for the server to start ..."
				[ ] // "**"
				[ ] // "The Administration Server has been restarted!"
				[ ] // ""
	[ ] // AdministrationServerConsol.JavaDialogBox("Restart Server").SetActive ()
	[ ] AdministrationServerConsol.JavaDialogBox("Restart Server").JavaJFCPushButton("Close").Click ()
	[ ] // AdministrationServerConsol.SetActive ()
	[ ] AGPrint("CONF-log: Server has been restarted")
	[ ] 
	[ ] AGPrint("CONF-log: Editing allowed IP Address")
	[ ] 
	[ ] // AdministrationServerConsol.JavaDialogBox("#1").SetActive ()
	[+] // if ! ( AdministrationServerConsol.JavaDialogBox("#1").Exists() )
		[ ] // AGLogError ( "CONF-err: Message Dialog Not Found" )
		[ ] // // return
	[ ] // AdministrationServerConsol.JavaDialogBox("#1").JavaJFCPushButton(sConsole_OK).Click ()
	[ ] AdministrationServerConsol.AdministrationServer1.Select (sConsole_Configuration)
	[+] AdministrationServerConsol.AdministrationServer1.RightTabs.JavaJFCListBox("#1").VerifyProperties ({...})
		[ ] ""
		[-] {...}
			[ ] {"MultiSelIndex",        [LIST OF INTEGER] {2}}
			[ ] {"MultiSelText",         [LIST OF STRING] {sTST_CONF_HostIP}}
	[ ] AGPrint("CONF-log: Allowed IP Address that was saved has been found")
	[ ] //
	[ ] //
	[ ] EditIPAddress.Invoke() 
	[+] if ! ( AdministrationServerConsol.JavaDialogBox(sConsole_EditIPAddress).Exists() )
		[ ] AGLogError ( "CONF-err: Edit Host Name Dialog Box Not Found" )
		[ ] // return
	[ ] AGPrint("CONF-log: Editing IP Address allowed to {sTST_CONF_HostIPEdit}")
	[ ] EditIPAddress.IPAddress.SetText (sTST_CONF_HostIPEdit) 
	[ ] EditIPAddress.JavaJFCPushButton(sConsole_OK).Click ()
	[ ] AGPrint("CONF-log: Saving the edited IP Address allowed")
	[ ] 
	[ ] AdministrationServerConsol.AdministrationServer1.Save.Click()
	[ ] AdministrationServerConsol.JavaDialogBox("#1").JavaJFCPushButton(sConsole_OK).Click()
	[ ] 
	[ ] AGPrint("CONF-log: Restart the server and verify that the new IP address allowed is listed")
	[ ] //
	[ ] // AdministrationServerConsol.SetActive ()
	[ ] AdministrationServerConsol.AdministrationServer1.Select(sConsole_Tasks)
	[ ] // AdministrationServerConsol.SetActive ()
	[ ] // Agent.SetOption (OPT_MOUSE_DELAY, 0.5)
	[ ] sBUFFER = AdministrationServerConsol.AdministrationServer1.RestartServerText.GetText ()
	[+] if ( sBUFFER == "Restart Server")
		[ ] AGPrint("CONF-log: Restarting the server now ....")
		[ ] 
	[ ] AdministrationServerConsol.AdministrationServer1.RestartServerButton2.SetFocus ()
	[ ] AdministrationServerConsol.AdministrationServer1.RestartServerText.Click (2, 46, 11)
	[ ] AdministrationServerConsol.JavaJFCPopupMenu("JPopupMenu").Click()
	[ ] //
	[+] // if ! ( AdministrationServerConsol.AdministrationServer1.RestartServerButton2.IsPressed () )
		[ ] // AGPrint("CONF-log: Restart Server Button NOT PRESSED")
	[+] // else
		[ ] // AGPrint("CONF-log: Restart Server Button PRESSED")
		[ ] // 
	[ ] // AdministrationServerConsol.JavaDialogBox("Restart Server").SetActive ()
	[+] AdministrationServerConsol.JavaDialogBox("Restart Server").JavaJFCTextField("#1").VerifyProperties ({...})
		[ ] ""
		[-] {...}
			[-] {"MultiText",            [LIST OF STRING] {...}}
				[ ] ""
				[ ] ""
				[ ] sConsole_IRR
				[ ] sConsole_RRA
				[ ] sConsole_WSR
				[ ] ""
				[ ] // "The Administration Server has been stopped!"
				[ ] // "Waiting for the server to start ..."
				[ ] // "**"
				[ ] // "The Administration Server has been restarted!"
				[ ] // ""
	[ ] // AdministrationServerConsol.JavaDialogBox("Restart Server").SetActive ()
	[ ] AdministrationServerConsol.JavaDialogBox("Restart Server").JavaJFCPushButton("Close").Click ()
	[ ] // AdministrationServerConsol.SetActive ()
	[ ] AGPrint("CONF-log: Server has been restarted")
	[ ] //
	[ ] //
	[ ] // Verify that the edits were saved after a restart of the server
	[ ] AdministrationServerConsol.AdministrationServer1.Select (sConsole_Configuration)
	[+] AdministrationServerConsol.AdministrationServer1.RightTabs.JavaJFCListBox("#1").VerifyProperties ({...})
		[ ] ""
		[-] {...}
			[ ] {"MultiSelIndex",        [LIST OF INTEGER] {2}}
			[ ] {"MultiSelText",         [LIST OF STRING] {sTST_CONF_HostIPEdit}}
	[ ] AGPrint("CONF-log: Edited allowed IP address verified")
	[ ] //
	[ ] AGPrint("CONF-log: Restoring the test application to the DefaultDirectoryState")
	[ ] AdministrationServerConsol.AdministrationServer1.RightTabs.Remove.Click()
	[ ] AdministrationServerConsol.AdministrationServer1.Save.Click()
	[ ] AGPrint("CONF-log: DONE!")
	[ ] 
	[ ] 
	[ ] 
	[ ] AdministrationServerConsol.Close()
	[ ] 
[ ] 
[ ] // Test the "Select Organizational Unit" dialog
[+] testcase Test14 ()
	[ ] 
	[ ] STRING sSelText = ""
	[ ] INTEGER iRows = 0
	[ ] BOOLEAN bOK = TRUE
	[ ] 
	[ ] // open dialog to select directory subtree in which to create the new entry
	[ ] 
	[ ] // **********
	[ ] // first time
	[ ] // **********
	[ ] Console.Tabs.Select (sConsole_TabUsersGroups)
	[ ] 
	[ ] UGTab.Selection.Select (sConsole_ComboBoxNewOU)
	[ ] 
	[ ] UGTab.Create.Click ()
	[ ] Sleep(1)
	[ ] 
	[ ] // in dialog to create the new entry select subtree "Groups"
	[ ] 
	[+] if SelectOrganizationalUnit.DirectorySubtree.FindItem ("Groups") == 0
		[ ] LogWarning ("WARNING: UGCreateItem: couldn't find subtree")
		[ ] SelectOrganizationalUnit.Cancel.Click ()
		[ ] bOK = FALSE
	[ ] 
	[+] if bOK
		[ ] SelectOrganizationalUnit.DirectorySubtree.Select ("Groups")
		[ ] SelectOrganizationalUnit.OK.Click ()
		[ ] Sleep (1)
		[ ] 
		[ ] JavaDialogBox1.JavaJFCPushButton("Cancel").Click ()
		[ ] 
		[ ] Sleep(1)
		[ ] 
		[ ] Print ("1: Could see SelectOrganizationalUnit dialog")
		[ ] 
		[ ] 
	[ ] // ***********
	[ ] // second time
	[ ] // ***********
	[ ] 
	[ ] Console.Tabs.Select (sConsole_TabUsersGroups)
	[ ] 
	[ ] UGTab.Selection.Select (sConsole_ComboBoxNewGroup)
	[ ] UGTab.Selection.Select (sConsole_ComboBoxNewOU)
	[ ] 
	[ ] UGTab.Create.Click ()
	[ ] Sleep(5)
	[ ] 
	[ ] 
	[ ] // at this point the test can't see dialog SelectOrganizationalUnit anymore, 
	[ ] // *** Error: Window '[JavaDialogBox]Select Organizational Unit' was not found
	[ ] // run test case again without restarting Console and you will get error already 
	[ ] // after the first call
	[ ] 
	[ ] 
	[+] if SelectOrganizationalUnit.DirectorySubtree.FindItem ("Groups") == 0
		[ ] 
		[ ] LogWarning ("WARNING: UGCreateItem: couldn't find subtree")
		[ ] SelectOrganizationalUnit.Cancel.Click ()
		[ ] bOK = FALSE
	[ ] 
	[+] if bOK
		[ ] 
		[ ] SelectOrganizationalUnit.DirectorySubtree.Select ("Groups")
		[ ] SelectOrganizationalUnit.OK.Click ()
		[ ] // Sleep (1)
		[ ] 
		[ ] JavaDialogBox1.JavaJFCPushButton("Cancel").Click ()
		[ ] 
		[ ] Print ("2: Could see SelectOrganizationalUnit dialog")
		[ ] 
	[+] if !bOK
		[ ] LogError ("Failed")
	[ ] 
	[ ] 
	[ ] 
	[ ] 
	[ ] Console.Tabs.Select ("Console")
	[ ] 
