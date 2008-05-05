[ ] // this file contains test case specific data for 8bit testing
[ ] 
[ ] // test strings for "User and Groups" test cases
[ ] 
[ ] 
[ ] // test strings for "Organizational Unit" test cases
[ ] STRING sTST_UG_Subtree_Master = "Base DN*"
[ ] STRING sTST_UG_OU_Master = "Mißßiön Çöntröl"
[ ] STRING sTST_UG_OU_Slave = "Aðmin Sérvèr"
[ ] 
[ ] // test strings for "Group" test cases
[ ] STRING sTST_UG_Group_Name = "äðmqä"
[ ] 
[ ] // test strings for "Users" test cases
[ ] STRING sTST_UG_User1_UserID = "JTtong"
[ ] STRING sTST_UG_User1_FirstName = "Jün"
[ ] STRING sTST_UG_User1_LastName = "Töng"
[ ] STRING sTST_UG_User1_FullName = "Jün Töng"
[ ] STRING sTST_UG_User2_UserID = "JCcho"
[ ] STRING sTST_UG_User2_FirstName = "Jeeßün"
[ ] STRING sTST_UG_User2_LastName = "Çhö"
[ ] STRING sTST_UG_User2_FullName = "Jeeßün Çhö"
[ ] STRING sTST_UG_User3_UserID = "WMmorris"
[ ] STRING sTST_UG_User3_FirstName = "Williäm"
[ ] STRING sTST_UG_User3_LastName = "Mörriß"
[ ] STRING sTST_UG_User3_FullName = "Williäm Mörriß"
[ ] STRING sTST_UG_User4_UserID = "PZzhang"
[ ] STRING sTST_UG_User4_FirstName = "Ðeter"
[ ] STRING sTST_UG_User4_LastName = "Zhäng"
[ ] STRING sTST_UG_User4_FullName = "Ðeter Zhäng"
[ ] 
[ ] // test strings needed for editing user
[ ] STRING sTST_UG_UserEdit_UserID = "ABecker"
[ ] STRING sTST_UG_UserEdit_FirstName = "Anðreäß"
[ ] STRING sTST_UG_UserEdit_LastName = "Becker"
[ ] STRING sTST_UG_UserEdit_FullName = "Anðreäß Becker"
[ ] STRING sTST_UG_UserEdit_Password = "Netscape"
[ ] STRING sTST_UG_UserEdit_EMail = "andreasb@netscape.com"
[ ] STRING sTST_UG_UserEdit_Phone = "(650) 937 - 5555"
[ ] STRING sTST_UG_UserEdit_Fax = "(555) 937 - 1234"
[ ] 
[ ] // test strings needed for editing OU
[ ] STRING sTST_UG_OUEdit_Name = "Eðiteð Mißßiön Çöntröl"
[ ] STRING sTST_UG_OUEdit_Description = "Thiß iß ä teßt för eðiting ÖÜ"
[ ] STRING sTST_UG_OUEdit_Phone = "(650) 555 ÿ 9387"
[ ] STRING sTST_UG_OUEdit_Fax = "(650) 555 ÿ 9387"
[ ] STRING sTST_UG_OUEdit_Alias = "Ace Inðüßtry"
[ ] STRING sTST_UG_OUEdit_Address = "Möüntäin View"
[ ] 
[ ] // ******************************
[ ] // test strings needed for search
[ ] // ******************************
[ ] 
[ ] // test data (simple and advance search)
[ ] STRING sTST_UG_Search_User1_UserID = "JDo"
[ ] STRING sTST_UG_Search_User1_FirstName = "Jön"
[ ] STRING sTST_UG_Search_User1_FullName = "Jön Ðö"
[ ] STRING sTST_UG_Search_User1_LastName = "Ðö"
[ ] STRING sTST_UG_Search_User2_UserID = "JSmith"
[ ] STRING sTST_UG_Search_User2_FirstName = "Jönäthän"
[ ] STRING sTST_UG_Search_User2_LastName = "Smith"
[ ] STRING sTST_UG_Search_User2_FullName = "Jönäthän Smith"
[ ] STRING sTST_UG_Search_OU_Name = "Jönäthän'ß Mißßiön Çöntröl"
[ ] STRING sTST_UG_Search_Group_Name = "Aðmin QÄ Sèrver"
[ ] 
[ ] // simple search: search record
[-] type tTST_UG_Search_RECORD is record
	[ ] STRING sValue
	[ ] INTEGER iFound
[ ] 
[ ] // simple search: search data
[+] LIST OF tTST_UG_Search_RECORD sTST_UG_Search_String = {...}
	[ ] {"jön", 3}
	[ ] {"jSmith", 1}
	[ ] {"ðÖ", 1}
	[ ] {"Jönäthän Smith", 1}
	[ ] {"hÄn smi", 1}
	[ ] {"jönäthän*", 2}
	[ ] {"*min QÄ sè*", 1}
[ ] 
[ ] // advanced search: search record
[+] type tTST_UG_AdvanceSearch_RECORD is record
	[ ] STRING sValue      // value to search for
	[ ] STRING sGroup      // search in user, group or both
	[ ] STRING sWhere      // specify where to search in (e.g. cn, uid)
	[ ] STRING sAttribut   // specify search attributes (e.g. equals)
	[ ] INTEGER iFound     // number of expected occurances, specify negative value for values not found for sAttribut set to NotEqual
[ ] 
[ ] // advanced search: search data
[+] LIST OF tTST_UG_AdvanceSearch_RECORD sTST_UG_AdvanceSearch_String = {...}
	[ ] {"jön", 			sConsole_SearchAdvanceComboBoxSearchUG, 
    					sConsole_SearchAdvanceComboBoxWhereCN, 
    					sConsole_SearchAdvanceComboBoxAttributContains, 
    		2}
	[ ] {"Aðmin QÄ Sèrver",	sConsole_SearchAdvanceComboBoxSearchUG, 
    					sConsole_SearchAdvanceComboBoxWhereCN, 
    					sConsole_SearchAdvanceComboBoxAttributEquals, 
    		1}
	[ ] {"dO",	 			sConsole_SearchAdvanceComboBoxSearchUG, 
    					sConsole_SearchAdvanceComboBoxWhereUID, 
    					sConsole_SearchAdvanceComboBoxAttributContains, 
    		1}
	[ ] {"jSmith",	 		sConsole_SearchAdvanceComboBoxSearchUG, 
    					sConsole_SearchAdvanceComboBoxWhereUID, 
    					sConsole_SearchAdvanceComboBoxAttributEquals, 
    		1}
	[ ] {"Aðmin Q",	 		sConsole_SearchAdvanceComboBoxSearchGroups, 
    					sConsole_SearchAdvanceComboBoxWhereCN, 
    					sConsole_SearchAdvanceComboBoxAttributContains, 
    		1}
	[ ] {"Aðmin QÄ Sèrver", sConsole_SearchAdvanceComboBoxSearchGroups, 
    					sConsole_SearchAdvanceComboBoxWhereCN, 
    					sConsole_SearchAdvanceComboBoxAttributDoesNotEqual, 
    		-1}
	[ ] {"ö", 				sConsole_SearchAdvanceComboBoxSearchUsers, 
    					sConsole_SearchAdvanceComboBoxWhereCN, 
    					sConsole_SearchAdvanceComboBoxAttributContains, 
    		2}
	[ ] {"jdo", 			sConsole_SearchAdvanceComboBoxSearchUsers, 
    					sConsole_SearchAdvanceComboBoxWhereUID, 
    					sConsole_SearchAdvanceComboBoxAttributEquals, 
    		1}
[ ] 
[ ] 
