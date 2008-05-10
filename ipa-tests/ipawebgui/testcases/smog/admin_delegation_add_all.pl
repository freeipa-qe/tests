use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;

my $sel = Test::WWW::Selenium->new( host => "localhost", 
                                    port => 4444, 
                                    browser => "*firefox", 
                                    browser_url => "http://localhost:4444" ); 

# make sure the dns record has been setup 
$sel->open_ok(https://ipaserver.test.com/ipa/ipapolicy/show); 
$sel->wait_for_page_to_load_ok("30000");

$sel->click_ok("link=Delegations");
$sel->wait_for_page_to_load_ok("30000");
$sel->click_ok("link=add new delegation");
$sel->wait_for_page_to_load_ok("30000");
$sel->type_ok("form_name", "supervisor");
$sel->type_ok("source_criteria", "editor");
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
$sel->type_ok("dest_criteria", "a");
$sel->click_ok("//input[\@value='Find' and \@type='button' and \@onclick=\"return doSearch('dest');\"]");
$sel->click_ok("//a[\@onclick=\"selectGroup('dest', 'cn=admins,cn=groups,cn=accounts,dc=test,dc=com', 'admins');                 return false;\"]");
$sel->click_ok("submit");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("delegate created");
$sel->is_text_present_ok("supervisor 	editorgrp 	First Name, Last Name, Full Name, Title, Display Name, Initials, Login, Password, UID, GID, Home Directory, Login Shell, GECOS, E-mail Address, Work Number, Fax Number, Cell Number, Pager Number, Home Number, Street Address, City, State, ZIP, Org Unit, Tags, Description, Employee Type, Manager, Room Number, Secretary, Car License, Home Page 	admins");

