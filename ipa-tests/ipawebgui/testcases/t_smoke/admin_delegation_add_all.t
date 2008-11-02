
#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More tests => 50;
use Test::Exception;
use Net::LDAP;
use Net::LDAP::Util qw(ldap_error_text);

use lib '/home/yi/workspace/ipawebgui/support';
use IPAutil;
use IPADataStore;

# global veriables
our $configfile="test.conf";
our $testid=1029;
our $testdata;
our @datakeys=("form_name","source_criteria","dest_criteria");

our $host;
our $port;
our $browser;
our $browser_url;
our $sel;

our $ldap_server;
our $base;
our $scope;
our $adminpw;
our $ldap;

# read configruation file
our $config=IPAutil::readconfig($configfile);
$host=$config->{'host'};
$port=$config->{'port'};
$browser=$config->{'browser'};
$browser_url=$config->{'browser_url'};
$sel = Test::WWW::Selenium->new(host=>$host,port=>$port,browser=>$browser,browser_url=>$browser_url);

$ldap_server=$config->{'ldap_server'};
$base=$config->{'base'};
$scope=$config->{'scope'};
$adminpw = $config->{'adminpw'};
$ldap = Net::LDAP->new($ldap_server); 

## Test starts here 
IPAutil::env_check($host, $port, $browser, $browser_url, $ldap_server, $base, $scope, $adminpw);
prepare_data();
run_test($testdata);
cleanup_data($testdata);


#=========== sub =============

sub run_test {
   # test case name (admin_delegation_add_all) from source (admin_delegation_add_all.pl)
   # auto generated at 2008/5/16:10:54:41
	#$sel->open_ok(https://ipaserver.test.com/ipa/ipapolicy/show); 
	$sel->open_ok("/ipa/ipapolicy/show"); 
	$sel->wait_for_page_to_load_ok("30000");
	$sel->click_ok("link=Delegations");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->click_ok("link=add new delegation");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->type_ok("form_name", "$testdata->{'form_name'}");
	$sel->type_ok("source_criteria", "$testdata->{'source_criteria'}");
	$sel->click_ok("//input[\@value='Find']");
	$sel->is_text_present_ok("editorgrp select");
	$sel->click_ok("link=select");
	$sel->click_ok("form_attrs_givenname");
	$sel->click_ok("form_attrs_sn");
	$sel->click_ok("form_attrs_cn");
	$sel->click_ok("form_attrs_title");
	$sel->click_ok("form_attrs_displayname");
	$sel->click_ok("form_attrs_initials");
	$sel->click_ok("form_attrs_uid");
	$sel->click_ok("form_attrs_krbprincipalkey");
	$sel->click_ok("form_attrs_uidnumber");
	$sel->click_ok("form_attrs_gidnumber");
	$sel->click_ok("form_attrs_homedirectory");
	$sel->click_ok("form_attrs_loginshell");
	$sel->click_ok("form_attrs_gecos");
	$sel->click_ok("form_attrs_mail");
	$sel->click_ok("form_attrs_telephonenumber");
	$sel->click_ok("form_attrs_facsimiletelephonenumber");
	$sel->click_ok("form_attrs_mobile");
	$sel->click_ok("form_attrs_pager");
	$sel->click_ok("form_attrs_homephone");
	$sel->click_ok("form_attrs_street");
	$sel->click_ok("form_attrs_l");
	$sel->click_ok("form_attrs_st");
	$sel->click_ok("form_attrs_postalcode");
	$sel->click_ok("form_attrs_ou");
	$sel->click_ok("form_attrs_businesscategory");
	$sel->click_ok("form_attrs_description");
	$sel->click_ok("form_attrs_employeetype");
	$sel->click_ok("form_attrs_manager");
	$sel->click_ok("form_attrs_roomnumber");
	$sel->click_ok("form_attrs_secretary");
	$sel->click_ok("form_attrs_carlicense");
	$sel->click_ok("form_attrs_labeleduri");
	$sel->type_ok("dest_criteri$testdata->{'dest_criteria'}", "a");
	$sel->click_ok("//input[\@value='Find' and \@type='button' and \@onclick=\"return doSearch('dest');\"]");
	$sel->click_ok("//a[\@onclick=\"selectGroup('dest', 'cn=admins,cn=groups,cn=accounts,dc=test,dc=com', 'admins');                 return false;\"]");
	$sel->click_ok("submit");
	$sel->wait_for_page_to_load_ok("30000");
	$sel->is_text_present_ok("delegate created");
	$sel->is_text_present_ok("supervisor 	editorgrp 	First Name, Last Name, Full Name, Title, Display Name, Initials, Login, Password, UID, GID, Home Directory, Login Shell, GECOS, E-mail Address, Work Number, Fax Number, Cell Number, Pager Number, Home Number, Street Address, City, State, ZIP, Org Unit, Tags, Description, Employee Type, Manager, Room Number, Secretary, Car License, Home Page 	admins");
} #admin_delegation_add_all


sub prepare_data{
	$testdata = IPADataStore::construct_testdata($testid, @datakeys); 
}

sub cleanup_data{
	IPADataStore::cleanup_testdata($testid, $testdata);
}
