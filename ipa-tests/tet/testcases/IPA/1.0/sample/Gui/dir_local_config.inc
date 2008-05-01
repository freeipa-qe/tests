[ ] // Slapd Variables 
[ ] STRING sHOST1="jupiter2"
[ ] STRING sDOMAIN1="mcom.com"
[ ] STRING sConsole_LDAPPortNum="40411"
[ ] STRING sConsole_USERID="cn=directory manager"
[ ] STRING sConsole_PASSWORD="secret12"
[ ] STRING sConsole_PortNumber="40410"
[ ] // Case of Unix Server
[ ] BOOLEAN bUnixServer = TRUE
[ ] STRING sUNIXServerRoot = "/export1/lgopal/41/slapd-jupiter2"
[ ] STRING sUNIX_CMD="/export1/lgopal/41/slapd-jupiter2/../java/MCC"
[ ] //For NT server Testing
[ ] STRING sNTServerRoot = "/export1/lgopal/41/slapd-jupiter2/.."
[ ] ntsrv STRING sNT_DIR = sNTServerRoot
[ ] ntsrv STRING sNT_CMD = "{sNTServerRoot}/MCC.bat"
[ ] STRING sNTCMD = "{sNTServerRoot}/MCC.bat"
[ ] BOOLEAN bSecureServer = FALSE
[ ] STRING sTokenPassword = "secret12"
[ ] BOOLEAN bSLAPD_local = TRUE
[ ] STRING sResultFile = "F:\tetframework\testcases\DS\4.1\tet_tmp_dir\test.out"
[ ] STRING sDummyStartFile = "F:/tetframework/testcases/DS/4.1/sample/Gui/engagestart.txt"
[ ] STRING sDummyEndFile = "F:/tetframework/testcases/DS/4.1/sample/Gui/engageend.txt"
