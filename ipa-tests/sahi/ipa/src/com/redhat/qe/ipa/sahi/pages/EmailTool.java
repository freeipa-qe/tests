package com.redhat.qe.ipa.sahi.pages;
	
import javax.mail.*;
import javax.mail.internet.*;
import java.util.*;
	
public class EmailTool {
 
	public static void main(String[] args)
	{
		String emailServer = "smtp.corp.redhat.com";
		String to="yzhang@redhat.com";
		String from="ipaqa@redhat.com";
		String subject="test automation result";
		String report= "==================== Test Result Summary ========================";
		EmailTool postman = new EmailTool(emailServer, from, to, subject, report);
		postman.deliver();
	}
	
	private String emailServer, from, to, subject, report;
	
	public EmailTool(String emailServer,String from, String to, String subject, String report )
	{
		this.emailServer = emailServer;
		this.from = from;
		this.to = to;
		this.subject = subject;
		this.report = report;
	}
	
	public boolean deliver()
	{ 
		int delayCounter = 0;
		int maxWaitTime = 60; // try max 1 minutes (60 seconds)
		int delayDuration = 5;
		int totalWaitTime=0;
		boolean send = false;
		do { 
			try {
				Properties props = new Properties();
				props.put("mail.smtp.host", emailServer) ; 
				props.put("mail.smtp.port", "25"); 
				Session session = Session.getInstance(props);
				      
				Address fromAddr = new InternetAddress(from, "IPA WebUI Automation");
				Address toAddr = new InternetAddress(to, "Yi Zhang"); 
				     
				Message message = new MimeMessage(session); 
				message.setFrom(fromAddr);
				message.setRecipient(Message.RecipientType.TO, toAddr);
				message.setSubject(subject);
				message.setContent(report, "text/plain");
				      
				Transport.send(message);
				System.out.println("Send success");
				send=true; //
			}catch (Exception e) {
				e.printStackTrace(); 
				System.out.println("Send Failed"); 
			}
			if (!send){
				delayCounter++;
				int currentWaitTime = delayCounter * delayDuration;
				totalWaitTime += currentWaitTime;
				System.out.println("re-send in: "+ currentWaitTime + " seconds");
				try{
					 Thread.currentThread().sleep(totalWaitTime);
				}catch(InterruptedException e){
					 //do nothing
				}
			} 
		}while (!send || (totalWaitTime > maxWaitTime) ); 
	    return send;
	  } 
}
