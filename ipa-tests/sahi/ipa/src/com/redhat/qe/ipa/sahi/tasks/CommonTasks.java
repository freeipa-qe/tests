package com.redhat.qe.ipa.sahi.tasks;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.logging.Logger;

import javax.annotation.processing.FilerException;

import org.testng.annotations.BeforeMethod;

import com.redhat.qe.auto.testng.Assert;



public class CommonTasks {
	private static Logger log = Logger.getLogger(CommonTasks.class.getName());
	
	//public static String serverUrl = System.getProperty("ipa.server.url");
	public static String serverUrl = System.getProperty("ipa.server.url");
	public static String adDomain = System.getProperty("ad.domain");
	public static String userPage = serverUrl + "/ipa/ui/index.html#/e/user/search";
	public static String groupPage = serverUrl + "/ipa/ui/index.html#/e/group/search";
	public static String hostPage = serverUrl + "/ipa/ui/index.html#/e/host/search";
	public static String hostgroupPage =  serverUrl + "/ipa/ui/index.html#/e/hostgroup/search";
	public static String netgroupPage =  	serverUrl + "/ipa/ui/index.html#/e/netgroup/search";																				
	public static String dnsPage =  serverUrl + "/ipa/ui/index.html#/e/dnszone/search";
	public static String dnsConfigPage = serverUrl + "/ipa/ui/index.html#/e/dnsconfig/details"; 		
	//public static String alternateDNSpage = serverUrl + "/ipa/ui/index.html#/e/		
	public static String passwordPolicyPage = serverUrl + "/ipa/ui/index.html#/e/pwpolicy/search"; 		
	public static String kerberosTicketPolicyPage =  serverUrl + "/ipa/ui/index.html#/e/krbtpolicy/details";		
	public static String servicePage = serverUrl + "/ipa/ui/index.html#/e/service/search"; 		
	public static String selfservicepermissionPage = serverUrl + "/ipa/ui/index.html#/e/selfservice/search";		
	public static String hbacPage =  serverUrl + "/ipa/ui/index.html#/e/hbacrule/search";		
	public static String hbacServicePage =  serverUrl + "/ipa/ui/index.html#/e/hbacsvc/search";		
	public static String hbacServiceGroupPage = serverUrl + "/ipa/ui/index.html#/e/hbacsvcgroup/search"; 		
	public static String hbacTest = serverUrl + "/ipa/ui/index.html#/e/hbactest/user"; 		
	public static String sudoRulePage = serverUrl + "/ipa/ui/index.html#/e/sudorule/search"; 		
	public static String sudoPage=sudoRulePage;		
	public static String sudoCommandPage = serverUrl + "/ipa/ui/index.html#/e/sudocmd/search"; 		
	public static String sudoCommandGroupPage = serverUrl + "/ipa/ui/index.html#/e/sudocmdgroup/search"; 		
	public static String configurationPage = serverUrl + "/ipa/ui/index.html#/e/config/details";
	public static String automountPage = serverUrl + "/ipa/ui/index.html#/e/automountlocation/search";
	public static String hbacRulesPolicyPage = serverUrl + "/ipa/ui/index.html#/e/hbacrule/search";
	public static String rolePage = serverUrl + "/ipa/ui/index.html#/e/role/search";
	public static String privilegePage = serverUrl + "/ipa/ui/index.html#/e/privilege/search";
	public static String permissionPage = serverUrl + "/ipa/ui/index.html#/e/permission/search";
	public static String delegationPage = serverUrl + "/ipa/ui/index.html#/e/delegation/search";
	public static String automemberUserGroupPage = serverUrl + "/ipa/ui/index.html#/e/automember/searchgroup";
	public static String automemberHostGroupPage = serverUrl + "/ipa/ui/index.html#/e/automember/searchhostgroup";
	public static String trustsPage = serverUrl + "/ipa/ui/index.html#/e/trust/search"; 
	public static String selinuxPage = serverUrl + "/ipa/ui/index.html#/e/selinuxusermap/search";
	
	
	
	public static String ipadomain = "";
	public static String ipafqdn= "";
	public static String reversezone = "";
	public static String realm="";
	
	
	public CommonTasks() {
		setErrorFlag(false);
		serverUrl = System.getProperty("ipa.server.url");
		setIpadomain(System.getProperty("ipa.server.domain"));
		setIpafqdn(System.getProperty("ipa.server.fqdn"));
		setReversezone(System.getProperty("ipa.server.reversezone"));
		setIPARealm(System.getProperty("ipa.server.realm"));		
	}
	
	


	// to check if unexpected error was thrown in a test
	public static boolean errorFlag = false;

	
	
    public static boolean isErrorFlag() {
		return errorFlag;
	}

	public static void setErrorFlag(boolean errorFlag) {
		CommonTasks.errorFlag = errorFlag;
	}

	public String getIpadomain() {
		return ipadomain;
	}

	public static void setIpadomain(String ipadomain) {
		CommonTasks.ipadomain = ipadomain;
	}

	public static String getIpafqdn() {
		return ipafqdn;
	}

	public static void setIpafqdn(String ipafqdn) {
		CommonTasks.ipafqdn = ipafqdn;
	}

	public String getReversezone() {
		return reversezone;
	}
	
	public static void setReversezone(String reversezone) {
		CommonTasks.reversezone = reversezone;
	}
	
	
	private void setIPARealm(String realm) {
		CommonTasks.realm = realm;
	}
	
	public static boolean kinitAsAdmin() {    	
        String admin=System.getProperty("ipa.server.admin");
        String password=System.getProperty("ipa.server.password");        
        return kinitAsUser(admin, password);    	
	}
    // form based auth
	//kdestroy
	//recorded actions 
	public static void formauthNewUser(SahiTasks sahiTasks, String userName, String password, String newpassword){
		try{
			sahiTasks.open();
            String osname=System.getProperty("os.name");
            if (!System.getProperty("os.name").startsWith("Windows"))
                Runtime.getRuntime().exec("kdestroy");
            sahiTasks.navigateTo(serverUrl, true);

            if(!sahiTasks.link("form-based authentication").exists()){

                    if(sahiTasks.link("Logout").exists()){

                            sahiTasks.link("Logout").click();
                            if (!System.getProperty("os.name").startsWith("Windows"))
                               Runtime.getRuntime().exec("kdestroy");
                            if(sahiTasks.link("Return to main page.").exists()){
                                    sahiTasks.link("Return to main page.").click();
                            }
                    }
            }
            if(sahiTasks.link("form-based authentication").exists()){
                    sahiTasks.link("form-based authentication").click();
            }
            sahiTasks.textbox("username").setValue(userName);
            sahiTasks.password("password").setValue(password);

            sahiTasks.button("Login").click();
            //for a new user ,new_password should always exist,need to verificate for bug 782981
            //if(sahiTasks.password("new_password").exists()){
            Assert.assertTrue(sahiTasks.password("new_password").exists(),"reset password for first time login");
            sahiTasks.password("new_password").setValue(newpassword);
            sahiTasks.password("verify_password").setValue(newpassword);
            sahiTasks.button("Reset Password and Login").click();
            //}
            Assert.assertTrue(CommonTasks.kinitAsUser(userName, newpassword), "Logged in successfully as " + userName);			
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void formauth(SahiTasks sahiTasks, String userName, String password, boolean expect){
		formauth(sahiTasks, userName,  password);
		if (!expect)
			Assert.assertTrue(sahiTasks.div("error-box").exists(), "Verify " + userName + " cannot login");	
		else
			Assert.assertTrue(sahiTasks.span("Logged In As").exists(), "Logged in successfully as " + userName);
				
	}
	
	public static void formauth(SahiTasks sahiTasks, String userName, String password){
		try{
			sahiTasks.open();
			String osname=System.getProperty("os.name");
			if (!System.getProperty("os.name").startsWith("Windows"))
  			    Runtime.getRuntime().exec("kdestroy");
			sahiTasks.navigateTo(serverUrl, true);
			
			if(!sahiTasks.link("form-based authentication").exists()){
				
				if(sahiTasks.link("Logout").exists()){
					
					sahiTasks.link("Logout").click();
					if (!System.getProperty("os.name").startsWith("Windows"))
					   Runtime.getRuntime().exec("kdestroy");
					if(sahiTasks.link("Return to main page.").exists()){
						sahiTasks.link("Return to main page.").click();
					}
				}
			}
			if(sahiTasks.link("form-based authentication").exists()){
				sahiTasks.link("form-based authentication").click();
			}
			sahiTasks.textbox("username").setValue(userName);
			sahiTasks.password("password").setValue(password);
			
			sahiTasks.button("Login").click();
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
    public static boolean kinitAsUser(String user, String password) {
    	if (System.getProperty("os.name").startsWith("Windows")) {
    		log.finer("Attempting to kinit on Windows");
    		return true;
    	} 	
    	try {
    		Process process = Runtime.getRuntime().exec("kinit " +  user);
    		
    		OutputStream stdin = process.getOutputStream ();    	    
    	    String line = password + "\n";   
    	    stdin.write(line.getBytes() );
    	    stdin.flush();
    	    
    		BufferedReader input =
    	        new BufferedReader
    	          (new InputStreamReader(process.getInputStream()));
    		while ((line = input.readLine()) != null) {
    	        log.finer(line);
    	      }
    		
    		BufferedReader error =
    	        new BufferedReader
    	          (new InputStreamReader(process.getErrorStream()));
    		while ((line = error.readLine()) != null) {
    	        log.finer(line);
    	        return false;
    	      }
    		
    		stdin.close();    	
		} catch (IOException e) {
			e.printStackTrace();
		}
		return true;		
	}
    
    /* Set initial password for user in UI. Then here, can do a first kinit, 
     * where user is prompted to reset password.
     */
    public static boolean kinitAsNewUserFirstTime(String user, String password, String newPassword) {
    	if (System.getProperty("os.name").startsWith("Windows")) {
    		log.finer("Attempting to kinit on Windows");
    		return true;
    	} 
    	try {
    		Process process = Runtime.getRuntime().exec("kinit " +  user);
    		
    		OutputStream stdin = process.getOutputStream ();    	    
    	    String line = password + "\n";   
    	    stdin.write(line.getBytes() );
    	    stdin.flush();
    	    line = newPassword + "\n";   
    	    stdin.write(line.getBytes() );
    	    stdin.flush();
    	    line = newPassword + "\n";   
    	    stdin.write(line.getBytes() );
    	    stdin.flush();
    	    
    		BufferedReader input =
    	        new BufferedReader
    	          (new InputStreamReader(process.getInputStream()));
    		while ((line = input.readLine()) != null) {
    	        log.finer(line);
    	      }
    		
    		BufferedReader error =
    	        new BufferedReader
    	          (new InputStreamReader(process.getErrorStream()));
    		while ((line = error.readLine()) != null) {
    	        log.finer(line);
    	        return false;
    	      }
    		
    		stdin.close();    	
		} catch (IOException e) {
			e.printStackTrace();
		}
		return true;		
		
	}
    
    /*
     * Generates and returns a CSR for the provided hostname
     * Example:
     * String csr = CommonTasks.generateCSR("hp-dl360g5-02.testrelm");
     * 
     */
    public static String generateCSR(String hostname) {
    	String csr="";
    	Process process;
    	String tmp=System.getProperty("user.dir");
		try {
			if (System.getProperty("os.name").startsWith("Windows"))
				process=Runtime.getRuntime().exec(System.getProperty("user.dir") + "/scripts/generateCSR.bat " + hostname);
			else
				process = Runtime.getRuntime().exec(System.getProperty("user.dir") + "/scripts/generateCSR.sh " + hostname);
			try
			{
			Thread.sleep(15000); // do nothing for 15000 miliseconds (15 second)
			}
			catch(InterruptedException e)
			{
			e.printStackTrace();
			}
			
			if (System.getProperty("os.name").startsWith("Windows"))
			{
				FileInputStream fstream = new FileInputStream(hostname+".csr");
				if (!System.getProperty("os.name").startsWith("Windows")) 
					fstream = new FileInputStream("/tmp/"+hostname+".csr");
			
				DataInputStream in = new DataInputStream(fstream);
				BufferedReader br = new BufferedReader(new InputStreamReader(in));
				String strLine;
				boolean createcsr = false;
			  
				while ((strLine = br.readLine()) != null)   {
					if (strLine.equals("-----END NEW CERTIFICATE REQUEST-----") ){
						createcsr = false;
					}
					if (createcsr) {
						csr = csr + strLine + "\n"; 
					}
					if (strLine.equals("-----BEGIN NEW CERTIFICATE REQUEST-----")) {
						createcsr = true;
					}
				}
				
				in.close();		
			}
			else
			{
			
				FileInputStream fstream = new FileInputStream("/tmp/" + hostname+".csr");
				if (!System.getProperty("os.name").startsWith("Windows")) 
					fstream = new FileInputStream("/tmp/"+hostname+".csr");
			
				DataInputStream in = new DataInputStream(fstream);
				BufferedReader br = new BufferedReader(new InputStreamReader(in));
				String strLine;
				boolean createcsr = false;
			  
				while ((strLine = br.readLine()) != null)   {
					if (strLine.equals("-----END NEW CERTIFICATE REQUEST-----") ){
						createcsr = false;
					}
					if (createcsr) {
						csr = csr + strLine + "\n"; 
					}
					if (strLine.equals("-----BEGIN NEW CERTIFICATE REQUEST-----")) {
						createcsr = true;
					}
				}
				
				in.close();
				
			}
			
			
			
		} 
		catch (IOException e) {
			e.printStackTrace();
		}
		
		return csr;
    }
    
    //Generate ssh keys
    public static String generateSSH(String userId, String keyType, String keyFileName) {
    	String sshpubkey="";
    	Process process;
    	String sshkeyfile=keyFileName;
    	if (!System.getProperty("os.name").startsWith("Windows"))
    		sshkeyfile="/tmp/" + keyFileName;
    	String sshkeygencmd="ssh-keygen";
    	if (System.getProperty("os.name").startsWith("Windows"))
    		sshkeygencmd="C:\\rhcygwin\\bin\\ssh-keygen";
		try {
			boolean exists=(new File(sshkeyfile + ".pub")).exists();
			if(!exists){
				process = Runtime.getRuntime().exec(sshkeygencmd + " -t " + keyType + " -f " + sshkeyfile + " -P 11111111");
				try
				{
				Thread.sleep(15000); // do nothing for 15000 miliseconds (15 second)
				}
				catch(InterruptedException e)
				{
				e.printStackTrace();
				}
			}
			
			FileInputStream fstream = new FileInputStream(sshkeyfile + ".pub");
					
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			boolean createssh = false;
			int countspace=0;
			while ((strLine=br.readLine()) != null)   {
				
					sshpubkey = sshpubkey + strLine;
					
			}
			in.close();			    
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return sshpubkey;
    }
    
    /**
     * Search for an object - a user/host/group....
     * @param sahiTasks
     * @param objectToSearch - search string
     */
    public static void search(SahiTasks sahiTasks, String objectToSearch) {
		sahiTasks.textbox("filter").setValue(objectToSearch);
		sahiTasks.span("icon search-icon").click();
	}	
	
	/**
	 * Clear the search - so that all objects are listed
	 * @param sahiTasks
	 */
	public static void clearSearch(SahiTasks sahiTasks) {
		sahiTasks.textbox("filter").setValue("");
		sahiTasks.span("icon search-icon").click();
	}
	
	
	/*
	 * If a test throws an unexpected error, it will leave the test in that page, and tests 
	 * that follow it, will not start from the page they expect to be on.
	 * This method allows you to check for any unexpected error, and sets a flag
	 * 
	 * Example:
	 * In your task - 
	 * if (CommonTasks.checkError(sahiTasks)){
	 * 		Assert.fail("Unexpected error when testing with Name: " + record_name + ", Data: " + record_data + ", Type: " + record_type);
	 * 	}
	 * 
	 * In your test class -
	 * import org.testng.annotations.BeforeMethod;
	 * @BeforeMethod (alwaysRun=true)
	 * 	public void checkErrorFlag() {
	 * 		if (CommonTasks.isErrorFlag())
	 * 			sahiTasks.navigateTo(CommonTasks.dnsPage);
	 * 	}
	 * 
	 * The BeforeMethod will always run before every test method, ensuring you always 
	 * start from expected page
	 */
	public static boolean checkError(SahiTasks sahiTasks) {
		if ( (sahiTasks.div("/IPA Error */").exists()) || (sahiTasks.span("Required field").exists()) ){
			log.fine("IPA error dialog appears, usually this is data format error");
			// there will be multiple cancel button here
			if (!System.getProperty("os.name").startsWith("Windows")){
				while (sahiTasks.span("Cancel").exists()) {// cancel some error prompts existing on top of add prompt
					sahiTasks.span("Cancel").click();
				}
				while (sahiTasks.button("Cancel").exists()) {
					sahiTasks.button("Cancel").click();
				}
				
			}else{
				
				while (sahiTasks.span("Cancel").near(sahiTasks.span("Retry")).exists()) {
					sahiTasks.span("Cancel").click();
				}
				while (sahiTasks.button("Cancel").exists()) {
					sahiTasks.button("Cancel").click();
				}
			}/*
				for (int i=0;i<10;i++){
					while (sahiTasks.button("Cancel" + [i]).exists()) {
						sahiTasks.button("Cancel").click();
				
				while (sahiTasks.span("Cancel").exists()) {// cancel some add prompts existing prior to the error prompt
					sahiTasks.span("Cancel").click();
				}
			}*/
			setErrorFlag(true);
			return true;
		}	
		return false;
	}
	
	
	
	
	/**
	 * Verify Membership
	 * Note: navigation to and from should be controlled by caller
	 * 
	 * @param sahiTasks
	 * @param member - the member being verify for - the username/groupname
	 * @param membertype - the type of member being verified - Users/User Groups
	 * @param memberOfType - the memberOf type to which the member belongs - User Groups/Netgroups/Roles/HBAC Rules/Sudo Rules
	 * @param memberOfName - the memberOf name to which the member belongs - the groupname/sudorulename
	 * @param type - is the member a direct/indirect memberof
	 * @param isMember - is the member expected to be exist - true/false
	 */
	public static void verifyMemberOf(SahiTasks sahiTasks, String member, String membertype, String memberOfType, String memberOfName,
			String type, boolean isMember) {		
		
		if (memberOfType == "User Groups"){
			sahiTasks.link("memberof_group").click();
		}
		if (memberOfType == "Netgroups"){
			sahiTasks.link("memberof_netgroup").click();
		}
		if (memberOfType =="Roles"){
			sahiTasks.link("memberof_role").click();
		}
		if (memberOfType == "HBAC Rules"){
			sahiTasks.link("memberof_hbacrule").click();
		}
		if (memberOfType == "Sudo Rules"){
			sahiTasks.link("memberof_sudorule").click();
		}
			
		
		sahiTasks.radio(type).click();
		
		if (isMember){
			Assert.assertTrue(sahiTasks.link(memberOfName).exists(), membertype + " " +  member + " is a " + type + 
					" member of " + memberOfType + " " + memberOfName);
		}
		else {
			Assert.assertFalse(sahiTasks.link(memberOfName).exists(), membertype + " " + member + " is NOT a " + type + 
					" member of " + memberOfType + " "+ memberOfName);
		}
		

		if (sahiTasks.link(membertype).in(sahiTasks.div("content")).exists())
			sahiTasks.link(membertype).in(sahiTasks.div("content")).click();
		
	}

	
	/*
	 * When modifying an object, and updating its desc to have trailing/leading space, it throws an error. 
	 * This method can be used to edit the desc, and then check for this error
	 */
	public static void modifyToInvalidSetting(SahiTasks sahiTasks, String cn, String fieldNameToUpdate, String description, String expectedError, String buttonToClick) {		
		sahiTasks.link(cn).click();
		sahiTasks.link("Settings").click();
		sahiTasks.textbox(fieldNameToUpdate).setValue(" ");
		sahiTasks.textbox(fieldNameToUpdate).setValue(description);
		sahiTasks.span("Update").click();
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error  :: " + expectedError);
		sahiTasks.button(buttonToClick).click();
		sahiTasks.span("undo").click();
		//in calling test, make sure to navigate back to page with cn
	}
	
	
	public static void modifyToInvalidSettingTextarea(SahiTasks sahiTasks, String cn, String fieldNameToUpdate, String description, String expectedError, String buttonToClick) {		
		sahiTasks.link(cn).click();
		sahiTasks.link("Settings").click();
		sahiTasks.textarea(fieldNameToUpdate).setValue(" ");
		sahiTasks.textarea(fieldNameToUpdate).setValue(description);
		sahiTasks.span("Update").click();
		Assert.assertTrue(sahiTasks.div(expectedError).exists(), "Verified expected error  :: " + expectedError);
		sahiTasks.button(buttonToClick).click();
		sahiTasks.span("undo").click();
		//in calling test, make sure to navigate back to page with cn
	}
	
	
	
	/*
	 * To help verify an expected error, when there is an
	 * Operations Error 
	 */
	public static void checkOperationsError(SahiTasks sahiTasks, String expectedError) {
		Assert.assertTrue(sahiTasks.span("Operations Error").exists(), "Verified Expected Error Message Header");
		//Assert.assertTrue(sahiTasks.div("Some operations failed.Show detailsHide details" + expectedError).exists(), "Verified Expected Error Message");
		sahiTasks.link("Show details").click();
		Assert.assertTrue(sahiTasks.listItem(expectedError).exists(), "Verified Expected Error Details when updating " +
				"category without deleting members");
		sahiTasks.button("OK").click();		
	}
	
	/* Execute an IPA CLI command
	 * @param command - command to execute
     */
    public static boolean executeIPACommand(String command) {
    	if (System.getProperty("os.name").startsWith("Windows")) {
    		log.finer("Attempting to execute an IPA command on Windows");
    		return true;
    	} 
    	else
    		kinitAsAdmin();
    	try {
    		Process process = Runtime.getRuntime().exec(command);
    		
    		OutputStream stdin = process.getOutputStream ();    	    
    	    String line = command + "\n";   
    	    stdin.write(line.getBytes() );
    	    //stdin.flush();
	        System.out.println("Executing Command: " + line);
    	    
    	    
    		BufferedReader input =
    	        new BufferedReader
    	          (new InputStreamReader(process.getInputStream()));
    		while ((line = input.readLine()) != null) {
    			System.out.println("Command Returned: " + line);
    	        log.finer(line);
    	      }
    		
    		BufferedReader error =
    	        new BufferedReader
    	          (new InputStreamReader(process.getErrorStream()));
    		while ((line = error.readLine()) != null) {
    	        log.finer(line);
    	        return false;
    	      }
    		
    		stdin.close();    	
		} catch (IOException e) {
			e.printStackTrace();
		}
		return true;		
	}
    
    /* Generate a keytab for an IPA principal
     * @param principal - principal to generate keytab for
     * @param keytabFile - ful path for keytab file
     */

    public static boolean getPrincipalKeytab (String principal, String keytabFile) {
    	if (System.getProperty("os.name").startsWith("Windows")) {
    		log.info("Attempting to run ipa-getkeytab on Windows");
    		return true;
    	} 
    	String command = "ipa-getkeytab -s " + CommonTasks.ipafqdn + " -p " + principal + " -k " + keytabFile;
    	boolean exists = (new File(keytabFile)).exists();
    	if (exists) {
    		boolean success = (new File (keytabFile)).delete();
    		if (!success) {
    			log.finer("Failed to delete " + keytabFile);
    		}	
    	} 

    	boolean commandsuccess = CommonTasks.executeIPACommand(command);
    	if (!commandsuccess) {
    		log.finer("Error executing ipa ipa getkeytab command: " + command);
    		return false;
    	}
    	return true;
    }	
}
