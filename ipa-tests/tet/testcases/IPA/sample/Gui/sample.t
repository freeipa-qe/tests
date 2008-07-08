[ ] 
[ ] use "dir_frame.inc"
[ ] use "dir_common_func.inc"
[ ] 
[ ] 
[ ] // Import Testing 
[ ] 
[ ] 
[-] testcase GuiStartTest() appstate ConfigurationState
	[ ] fStartTest()
[ ] 
[-] testcase GuiEndTest() appstate none
	[ ] fEndTest()
[ ] 
[ ] 
[ ] 
[-] testcase ImportStartup() appstate ConfigDatabaseSettingsState
	[ ] AGPrint("Import Startup")
	[ ] fAddSuffix()
	[ ] 
	[ ] 
[ ] 
[ ] //ConfigurationState
[+] testcase ImportWithAppendDatabase () appstate MenuImport
	[-] recording
		[-] do
			[-] if(ImportDatabase.Exists(20))
				[ ] ImportDatabase.SetActive ()
				[ ] Print("Import Database Found")
				[ ] // Select Options
				[ ] ImportDatabase.LDIFFileText.SetText(sDatabaseFile)
				[ ] ImportDatabase.DatabaseOptions.Select(2)
				[ ] // 
				[-] if (ImportDatabase.OK.IsEnabled())
					[ ] ImportDatabase.OK.Click()
				[-] else
					[ ] ImportDatabase.Cancel.Click()
					[ ] 
				[ ] 
				[ ] // Setting the Cation to Import Database[2] as this is the second dialog 
				[ ] // Displayed on the desktop with the same caption Import Database
				[ ] SetConfigDialogCaption(sImportCaption+"[2]")
				[-] if(ConfigConfirmation.Exists(60))
					[ ] ConfigConfirmation.SetActive ()
					[ ] ConfigConfirmation.OK.Click ()
		[-] except
			[ ] AGPrint( "Throw exception . Unable to Import")
[+] testcase ImportWithOverwriteDatabase () appstate MenuImport
	[-] recording
		[-] do
			[-] if(ImportDatabase.Exists(20))
				[ ] ImportDatabase.SetActive ()
				[ ] 
				[ ] // Select Options
				[ ] ImportDatabase.LDIFFileText.SetText(sDatabaseFile)
				[ ] ImportDatabase.DatabaseOptions.Select(1)
				[ ] 
				[ ] 
				[-] if (ImportDatabase.OK.IsEnabled())
					[ ] ImportDatabase.OK.Click()
				[-] else
					[ ] ImportDatabase.Cancel.Click()
				[ ] 
				[ ] //Confirmation
				[ ] 
				[ ] SetConfigDialogCaption(sImportCaption+"[2]")
				[-] if(ConfigConfirmation.Exists(60))
					[ ] ConfigConfirmation.SetActive ()
					[ ] ConfigConfirmation.OK.Click ()
				[ ] 
				[ ] 
				[ ] 
				[ ] 
				[ ] 
		[-] except
			[ ] Print( "Throw exception . Unable to Import")
[-] testcase ImportCleanup() appstate ConfigDatabaseSettingsState
	[ ] AGPrint("Import Cleanup")
	[ ] fDeleteSuffix()
	[ ] 
[ ] 
[ ] // Import GUI Testing
[ ] 
[+] Boolean ImportOKButtonEnabled()
	[ ] return ImportDatabase.OK.IsEnabled()
[ ] 
[+] testcase ImportDialogControls() appstate ConfigurationState
	[-] recording
		[-] do
			[ ] Configuration.DirectoryOptions.Select (sConfigDatabase)
			[ ] DirectoryMainWin.ObjectMenu.Import.Pick()
			[-] if(ImportDatabase.Exists(20))
				[ ] ImportDatabase.SetActive ()
				[ ] 
				[ ] // Initially the OK Button should be disabled
				[ ] 
				[ ] AGPrint("Test Case Description:When Import Dialog Box is opened , the OK button should be disabled ")
				[-] if(!ImportOKButtonEnabled())
					[ ] AGPrint("Test Status: Test Passed")
				[+] else
					[ ] AGPrint(" Test Failed ")
				[ ] 
				[ ] AGPrint("Test Case Description: Append To Database should be selected ")
				[+] if(ImportDatabase.DatabaseOptions.GetSelIndex()== 2 )
					[ ] AGPrint("Test Status: Test Passed")
				[+] else
					[ ] AGPrint(" Test Failed ")
					[ ] 
				[ ] 
				[ ] 
				[ ] ImportDatabase.LDIFFileText.SetText(sDatabaseFile)
				[ ] // OK button should get enabled 
				[ ] AGPrint("Test Case Description:When LdifFile is selected , the OK button should be enabled ")
				[-] if(ImportOKButtonEnabled())
					[ ] AGPrint("Test Status: Test Passed")
				[+] else
					[ ] AGPrint(" Test Failed ")
				[ ] 
				[ ] ImportDatabase.Cancel.Click()
				[ ] 
		[-] except 
			[ ] Print("Error in Import Dialog Controls ")
			[ ] ImportDatabase.Cancel.Click()
			[ ] 
	[ ] 
[ ] 
[ ] 
[ ] // Export Database 
[ ] // Functionality
[+] testcase ExportWithEntire () appstate configurationState
	[-] recording
		[-] do
			[ ] Configuration.DirectoryOptions.Select (sConfigDatabase)
			[ ] DirectoryMainWin.ObjectMenu.Export.Pick()
			[-] if(ExportDatabase.Exists(20))
				[ ] ExportDatabase.SetActive ()
				[ ] 
				[ ] // Select Options
				[ ] ExportDatabase.LDIFFileText.SetText(sDatabaseFile)
				[ ] ExportDatabase.DatabaseOptions.Select(1)
				[ ] 
				[ ] 
				[-] if (ExportDatabase.OK.IsEnabled())
					[ ] ExportDatabase.OK.Click()
				[-] else
					[ ] ExportDatabase.Cancel.Click()
				[ ] SetConfigDialogCaption(sExportCaption+"[2]")
				[+] if(ConfigConfirmation.Exists(60))
					[ ] ConfigConfirmation.SetActive ()
					[ ] ConfigConfirmation.OK.Click ()
				[ ] 
		[+] except
			[ ] Print( "Throw exception . Unable to Export")
[ ] 
[ ] // Export GUI testing 
[ ] 
[-] Boolean ExportOKButtonEnabled()
	[ ] return ExportDatabase.OK.IsEnabled()
[ ] 
[+] testcase ExportDiaologControls() appstate ConfigurationState
	[-] recording
		[-] do
			[ ] Configuration.DirectoryOptions.Select (sConfigDatabase)
			[ ] DirectoryMainWin.ObjectMenu.Export.Pick()
			[-] if(ExportDatabase.Exists(20))
				[ ] ExportDatabase.SetActive ()
				[ ] 
				[ ] // Initially the OK Button should be disabled
				[ ] 
				[ ] AGPrint("Test Case Description:When Export Dialog Box is opened , the OK button should be disabled ")
				[-] if(!ExportOKButtonEnabled())
					[ ] AGPrint("Test Status: Test Passed")
				[+] else
					[ ] AGPrint(" Test Failed ")
				[ ] 
				[ ] 
				[ ] AGPrint("Test Case Description: Entire datanase  should be selected ")
				[+] if(ExportDatabase.DatabaseOptions.GetSelIndex()== 1 )
					[ ] AGPrint("Test Status: Test Passed")
				[+] else
					[ ] AGPrint(" Test Failed ")
					[ ] 
				[ ] 
				[ ] ExportDatabase.LDIFFileText.SetText(sDatabaseFile)
				[ ] // OK button should get enabled 
				[ ] AGPrint("Test Case Description:When LdifFile is selected , the OK button should be enabled ")
				[-] if(ExportOKButtonEnabled())
					[ ] AGPrint("Test Status: Test Passed")
				[+] else
					[ ] AGPrint(" Test Failed ")
				[ ] 
				[ ] ExportDatabase.Cancel.Click()
				[ ] 
		[-] except 
			[ ] Print("Error in Export Dialog Default Controls GUI testing  ")
			[ ] ExportDatabase.Cancel.Click()
			[ ] 
	[ ] 
[ ] 
[ ] 
