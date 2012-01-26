# Role Based Access Control has 3 sets of clis: privilege, privilege and role
#  this will cover the functional tests 

ipaRBACFunctionalTests() {
    setup

    cleanup
}

setup()
{
    rlPhaseStartTest "Setup - add users and groups"
       rlRun "kinitAs $ADMINID $ADMINPW"
    rlPhaseEnd
}


test01()
{ 

    # test an existing role - say -
    # HelpDesk - can modify group memberships, modify users, reset password
    # add a user, assign Helpdesk role
    # kinit as this user
    # this user should be allowed to modify a user's lastname, reset password, but cannot add or delete this user
    # this user can add a user to another group, but cannot add or update a group
    # this user cannot list available hostgroups or netgroups, cannot delete them 

}

test02()
{

  # ipa permission-add ModifyGroupDescription --permissions=write --type=group --attr=description
  # ipa permission-add ModifyGroupBusinessCategory --permissions=write --type=group --attr=businesscategory
  # ipa privilege-add "Group Modifier"
  # ipa privilege-add-permission "Group Desc Modifier"
  # and add ModifyGroupDescription, ModifyGroupBusinessCategory
  # ipa role-add "TestGroupRole"
  # ipa role-add-privilege GroupRole and add "Group Modifier"
  # add user, and assign the role
  # Add a group for this test
  # kinit as this user
  # ipa group-mod --desc "group two after update"  grouptwo
  # ipa group-mod --addattr businesscategory=NK grouptwo
  # ipa group-mod --addattr seealso=NK grouptwo
  # ipa: ERROR: Insufficient access: Insufficient 'write' privilege to the 'seeAlso' attribute of entry 'cn=grouptwo,cn=groups,cn=accounts,dc=testrelm'.


}

test03()
{

# similar to above, but using filter, instead of type
# permission should be -
# ipa permission-show AAA --all
#   dn: cn=aaa,cn=permissions,cn=pbac,dc=testrelm,dc=com
#   Permission name: AAA
#   Permissions: write, add
#   Filter: (businesscategory=*)
#   Granted to Privilege: aaa
#   memberindirect: cn=aaa,cn=roles,cn=accounts,dc=testrelm,dc=com,
#         uid=one,cn=users,cn=accounts,dc=testrelm,dc=com
#   objectclass: groupofnames, ipapermission, top
}

test04()
{
# ipa permission-add AAA --permissions=write --targetgroup=groupone --attrs=description
# user with thi sperm can only update groupone's desc, and to
#  add members to this group, nor update desc for group two
}
