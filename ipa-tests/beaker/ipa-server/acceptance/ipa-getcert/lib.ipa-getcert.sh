######################################
# lib.ipa-getcert.sh                 #
######################################


qaRun()
{
    local cmd="$1"
    local out="$2"
    local expectCode="$3"
    local expectMsg="$4"
    local comment="$5"
    local debug=$6
    rlLog "cmd=[$cmd]"
    rlLog "expect [$expectCode], out=[$out]"
    rlLog "$comment"
    
    $1 2>&1 >$out
    actualCode=$?
    if [ "$actualCode" = "$expectCode" ];then
        rlLog "return code matches, now check the message"
        if grep -i "$expectMsg" $out 2>&1 >/dev/null
        then 
            rlPass "expected return code and msg matches"
        else
            rlFail "return code matches,but error message does not match as expected";
            debug="debug"
        fi
    else
        rlFail "expect [$expectCode] actual [$actualCode]"
        debug="debug"
    fi
    # if debug is defined
    if [ "$debug" = "debug" ];then
        echo "--------- expected msg ---------"
        echo "[$expectMsg]"
        echo "========== execution output ==============="
        cat $out
        echo "============== end of output =============="
    fi
} #qaRun
