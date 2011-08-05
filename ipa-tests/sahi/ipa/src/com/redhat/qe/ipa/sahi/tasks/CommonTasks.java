package com.redhat.qe.ipa.sahi.tasks;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.logging.Logger;



public class CommonTasks {
	private static Logger log = Logger.getLogger(CommonTasks.class.getName());
	
	public static String userPage = "/ipa/ui/#identity=user&navigation=identity";
	
	
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

}
