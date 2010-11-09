#/bin/sh

#ipa default libs

ipacompare()
{
    local label="$1"
    local expected="$2"
    local actual="$3"
    if [ "$actual" = "$expected" ];then
        rlPass "[$label] matches :[$expected]"
    else
        rlLog "expect [$expected], actual got [$actual]"
        rlFail "[$label] does NOT match"
    fi
}
