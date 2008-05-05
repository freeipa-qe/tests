[ ] // 
[ ] // \\ Test Data File for Console Configuration Tests//
[ ] //
[ ] // IMPORTANT NOTE:
[ ] // Modifications to this file should be done only after a code review and complete
[ ] // test execution and validation on all TIER 1 platforms.
[ ] // 
[ ] // Created by Sudesh Chandra on October 28th 1998
[ ] //
[+] // Revision History //
	[ ] // Date			By					Comments
	[ ] // --------------------------------------------------------------------------------
	[ ] // 10-28-98		Sudesh Chandra		Initial Creation
	[ ] // 									
[ ] //
[ ] //
[ ] //
[ ] STRING sTST_CONF_AdimistrationServer1 = "Admin-Serve"
[ ] //
[ ] STRING sTST_CONF_AdimistrationServer2 = "AdministrationServer"
[ ] //
[ ] STRING sTST_CONF_Configuration1 = "Cfg."
[ ] //
[ ] STRING sTST_CONF_Configuration2 = "Conf2"
[ ] //
[ ] // Log File Window
[ ] STRING sTST_CONF_LogAccess1 = "admin-serv/logs/Acc"
[ ] //
[ ] STRING sTST_CONF_LogAccess2 = "admin-serv/logs/"
[ ] //
[ ] STRING sTST_CONF_LogAccess3 = "admin-serv/"
[ ] //
[ ] LIST OF STRING lsTST_CONF_ValidLogVal = {"admin-serv/logs/123.txt", "admin-serv/logs/xxyyzz", "admin-serv/logs/lgfile1", "admin-serv/logs/123.log.txt"}
[ ] //
[ ] LIST OF STRING lsTST_CONF_InValidLogVal = {"admin-serv/", "admin-serv/lo/lgfile1", "admin-serv/logs/10-28-98/logfile1"}
[ ] //
[ ] LIST OF STRING lsTST_CONF_ValidErrLogVal = {"admin-serv/logs/123err.txt", "admin-serv/logs/xxyyzz-err", "admin-serv/logs/errfile1", "admin-serv/logs/123.errlog.txt", "admin-serv/logs/err/logfile1"}
[ ] //
[ ] LIST OF STRING lsTST_CONF_InValidErrLogVal = {"admin-serv/", "admin-serv/lo/errfile1", "admin-serv/logs/10-28-98/errlogfile1"}
[ ] //
[ ] // LIST OF STRING lsTST_CONF_LogError = {"admin-serv/logs/Err", "admin-serv/logs/", "admin-serv/logs", "admin-serv"}
[ ] //
[ ] // Network Config. Window \\
[ ] //
[ ] // Port Values
[ ] LIST OF STRING lsTST_CONF_PortVal = {"2","100","1000","1020","2000","4000","4444","5151","5999","6888","9999","10000"}
[ ] LIST OF STRING lsTST_CONF_PortInValid = {"0","AA00", "AAAA", "65538", "4444444444"}
[ ] //
[ ] // IP Values
[ ] LIST OF STRING lsTST_CONF_IPValid = {"208.12.63.5555","2.2.2.2","2.30.40.500","208.12.64.49"}
[ ] LIST OF STRING lsTST_CONF_IPInValid = {"208","208.12","208.12.63","20A8.2A0"}
[ ] //
[ ] // Host Names to allow
[ ] LIST OF STRING lsTST_CONF_Hosts = {"rabbit","rabbit.com","jack.rabbit.com","brer.rabbit.bear.com"}
[ ] STRING sTST_CONF_Host = "brer.rabbit.com"
[ ] STRING sTST_CONF_HostEdit = "BRER.BEAR.COM"
[ ] // Host IP Address to allow
[ ] LIST OF STRING lsTST_CONF_HostsIP = {"208.12.63.5555","2.2.2.2","2.30.40.500","208.12.64.49","208.*.*.*", "208.12.*.*", "208.12.64.*"}
[ ] // STRING sTST_CONF_AllMcomCom1 = "*.mcom.com"
[ ] STRING sTST_CONF_HostIP = "208.12.63.*"
[ ] STRING sTST_CONF_HostIPEdit = "208.*.*.*"
[ ] //
[ ] // Access Config. Window
[ ] STRING sTST_CONF_TST_CONF_UserName1 = "admin"
