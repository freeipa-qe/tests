package com.redhat.qe.ipa.sahi.tasks;

import java.io.BufferedReader;
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

}
