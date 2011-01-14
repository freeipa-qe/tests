
# delegation has 3 sets of clis: permission, privilege and role
#   therefore, 3 test case file have to be included

. ./t.permission.sh

ipadelegation() {
    permission
    privilege
    role
}
