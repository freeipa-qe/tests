package com.redhat.qe.ipa.sahi.pages;
import java.util.ArrayList;
import java.util.List;

import org.testng.xml.*;

public class IPATest {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		XmlSuite suite = new XmlSuite();
		suite.setName("ProgramaticRun");
		List<XmlClass> classes = new ArrayList<XmlClass>();
		classes.add(new XmlClass("test.failures.child"));
		

	}

}
