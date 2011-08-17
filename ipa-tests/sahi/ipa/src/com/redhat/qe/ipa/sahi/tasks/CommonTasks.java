package com.redhat.qe.ipa.sahi.tasks;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.logging.Logger;

import org.testng.annotations.BeforeMethod;

import com.redhat.qe.auto.testng.Assert;



public class CommonTasks {
	private static Logger log = Logger.getLogger(CommonTasks.class.getName());
	
	public static String userPage = "/ipa/ui/#identity=user&navigation=identity";	
	public static String groupPage = "/ipa/ui/#nagivation=identity&identity=group";
	public static String hostPage = "/ipa/ui/#identity=host&navigation=identity";
	public static String hostgroupPage = "/ipa/ui/#identity=hostgroup&navigation=identity";
	public static String netgroupPage = "/ipa/ui/#identity=netgroup&navigation=identity";
	public static String dnsPage = "/ipa/ui/#dns=dnszone&identity=dns&navigation=identity";
	public static String alternateDNSpage = dnsPage + "&dnszone-facet=search";
	public static String passwordPolicyPage = "/ipa/ui/#policy=pwpolicy&navigation=policy";
	public static String kerberosTicketPolicyPage = "/ipa/ui/#policy=krbtpolicy&navigation=policy";
	
	public static String hbacPage = "/ipa/ui/#hbac=hbacrule&policy=hbac&navigation=policy";	
	public static String sudoPage = "/ipa/ui/#navigation=policy&policy=sudo";
	
	public static String ipadomain = System.getProperty("ipa.server.domain");
	public static String ipafqdn= System.getProperty("ipa.server.fqdn");
	public static String reversezone = System.clearProperty("ipa.server.reversezone");
	
	// to check if unexpected error was thrown in a test
	public static boolean errorFlag = false;
	
    public static boolean isErrorFlag() {
		return errorFlag;
	}

	public static void setErrorFlag(boolean errorFlag) {
		CommonTasks.errorFlag = errorFlag;
	}

	public static boolean kinitAsAdmin() {    	
        String admin=System.getProperty("ipa.server.admin");
        String password=System.getProperty("ipa.server.password");        
        return kinitAsUser(admin, password);    	
	}
    
    public static boolean kinitAsUser(String user, String password) {
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
    	
		try {
			process = Runtime.getRuntime().exec(System.getProperty("user.dir") + "/scripts/generateCSR.sh " + hostname);
			try
			{
			Thread.sleep(10000); // do nothing for 5000 miliseconds (5 second)
			}
			catch(InterruptedException e)
			{
			e.printStackTrace();
			}
			
			FileInputStream fstream = new FileInputStream("/tmp/"+hostname+".csr");
		
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
			    
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return csr;
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
		if (sahiTasks.div("/IPA Error */").exists()){
			log.fine("IPA error dialog appears, usually this is data format error");
			// there will be two cancel button here
			if (sahiTasks.button("Cancel").exists()) {
				sahiTasks.button("Cancel").click();
			}
			if (sahiTasks.button("Cancel").exists()) {
				sahiTasks.button("Cancel").click();
			}
			setErrorFlag(true);
			return true;
		}	
		return false;
	}
	

}
