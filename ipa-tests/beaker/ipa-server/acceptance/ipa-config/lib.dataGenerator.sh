# lib.dataGenerator.sh

dataGenerator()
{
    # generate ipa testing data based on given condition
    local ipadatatype=$1
    shift
    local rest="$@"
    if [ "$ipadatatype" = "username" ];then
        GenerateUserName $rest
    elif [ "$ipadatatype" = "lastname" ];then
        GenerateUserName $rest
    elif [ "$ipadatatype" = "firstname" ];then
        GenerateUserName $rest
    elif [ "$ipadatatype" = "password" ];then
        GeneratePassword $rest
    else
        echo "Not supported"
    fi
} #dataGenerator

GenerateGroupName()
{
    # 1.3.6.1.4.1.1466.115.121.1.15  : Directory String 
    #generate group name based on syntax: 8bit string
    local length=$1
    if [ "$length" = "" ];then
        length=`getrandomint 1 255` #this is just a safe number
    fi
    groupname=`make_8bitString $length`
    echo "$groupname"
} #GenerateShellName

GenerateDomainName()
{
    # 1.3.6.1.4.1.1466.115.121.1.15  : Directory String 
    #generate group name based on syntax: 8bit string
    local length=$1
    if [ "$length" = "" ];then
        length=`getrandomint 1 255` #this is just a safe number
    fi
    domainname=`make_ascii_string $length` 
    echo "${domainname}.com"
} #GenerateShellName

GenerateShellName()
{
    #generate shell name based on syntax:
    local length=$1
    if [ "$length" = "" ];then
        length=`getrandomint 1 255` #this is just a safe number
    fi
    dirname=`GenerateFileName`
    string="/$dirame";
    filename=`GenerateFileName`
    string="$string/$filename"
    echo $string; 
} #GenerateShellName

GenerateFileName()
{
    #ipa file name may only include letters, numbers, _, -, .
    local length=$1
    if [ "$length" = "" ];then
        length=`getrandomint 1 255` #this is just a safe number
    fi
    local chars="0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _ . - +  ="
    local len=0
    local string=""
    while [ "$len" -lt "$length" ]
    do
        index=`getrandomint 1 67`
        char=`echo $chars | cut -d" " -f$index`
        string="${string}${char}"
        len=$((len+1))
    done
    unset length
    unset len
    echo $string
} #GenerateFileName

GenerateHomeDirectoryName()
{
    #ipa directory name may only include letters, numbers, _, -, .
    local length=$1
    if [ "$length" = "" ];then
        length=`getrandomint 1 255` #this is just a safe number
    fi
    local chars="0 1 2 3 4 5 6 7 8 9 / a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _ . - +  ="
    local len=0
    local string=""
    while [ "$len" -lt "$length" ]
    do
        index=`getrandomint 1 68`
        char=`echo $chars | cut -d" " -f$index`
        string="${string}${char}"
        len=$((len+1))
    done
    unset length
    unset len
    echo $string
} #GenerateUserName


GenerateUserName()
{
    #ipa user name may only include letters, numbers, _, -, . and $
    # and "$" can not be the first char
    local length=$1
    #rlLog "dataGenerator: username, length=[$length]"
    local chars="0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _ . - $"
    local leadingcharIndex=`getrandomint 1 64` #leading char can not be $
    local leadingchar=`echo $chars | cut -d" " -f$leadingcharIndex`
    local len=1
    local string="$leadingchar"
    while [ "$len" -lt "$length" ]
    do
        index=`getrandomint 1 66`
        char=`echo $chars | cut -d" " -f$index`
        string="${string}${char}"
        len=$((len+1))
    done
    unset length
    unset len
    echo $string
} #GenerateUserName

GeneratePassword()
{
    local length=$1
    local classes=$2
    if [ "$length" = "" ];then
        length=`getrandomint 1 8`
    fi
    if [ "$classes" = "" ];then
        classes=`getrandomint 1 5`
    fi
    pw=`make_password $length $classes`
    echo $pw
} #GeneratePassword

getrandomstring()
{
    local len=$1

    local i=0
    local string=""
    if [ -z $len ];then
        len=`getrandomint 1 15`
    fi
    local chars="a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
   while [ $i -lt $len ]; do
       index=`getrandomint 1 52`
       char=`echo $chars | cut -d" " -f$index`
       string="${string}${char}" 
       i=$((i+1))
   done
   echo $string
} #getrandomstring


getrandomint()
{
#usage: getrandomint <INT> to get random int between [0,INT]
#       getrandomint <INT INT> to get random int between [INT,INT]

    local i=0
    local seed=0
    local seed2=0
    local first=0
    local second=0
    local ceiling=0
    local floor=0
    local final=0
    for arg in $@;do
        i=$((i+1))
    done
    if [ $i -eq 0 ];then
        echo $RANDOM
        return
    elif [ $i -eq 1 ];then
        ceiling=$1
        floor=0
    else
        first=$1
        second=$2
        if [ $first -gt $second ];then
            ceiling=$first
            floor=$second
        else
            ceiling=$second
            floor=$first
        fi
    fi

    #echo "between: [$floor, $ceiling]"
    if [ $floor -eq $ceiling ];then
        final=$floor
        echo "$final"
        return
    fi
    diff=`echo "$ceiling - $floor + 1" | bc`
    seed=$RANDOM
    let "seed %= $ceiling"
    if [ $seed -lt $floor ];then
        seed2=$RANDOM
        let "seed2 = $seed2 % $diff "
        final=`echo "$floor + $seed2" | bc`
    else
        final=$seed
    fi
    echo $final
    return
    #echo "seed=$seed diff=$diff seed2=$seed2 final = [$final]"
} #getrandomint

make_8bitString()
{
    local length=$1
    if [ "$length" = "" ];then
        length=`getrandomint 1 255`
    fi
    local classes=5
    local outfile=$TmpDir/make_8bitstring.$RANDOM.out
    local allclasses="lowerl upperl digit special eightbits"
    local selectedclasses=""
    local i=0
    local finalString=""
    local this_char=""

    while [ $i -lt $classes ]
    do
        number=$RANDOM
        let "number %= 5"
        number=$((number+1)) #get random number in [1,2,3,4,5]
        field=`echo $allclasses | cut -d" " -f$number`
        #rlLog "num[$number],field=[$field]"
        if  echo $selectedclasses| grep $field 2>&1 >/dev/null
        then
            continue
        else
            selectedclasses="$selectedclasses $field"
            i=$((i+1))
        fi
    done
    # up to here, we might have: selectedclasses= lowerl upperl special
    field="" #this is just a symble reuse, it has no relation with previous value
    while [ $i -lt $length ]
    do
        let "index = $i % $classes"
        index=$((index+1))
        field=`echo $selectedclasses | cut -d" " -f$index`
        selectedclasses="$selectedclasses $field"
        i=$((i+1))
    done
    i=0
    for class in $selectedclasses
    do
        if [ $i -lt $length ] ;then
            this_char=`echo_random $class $outfile`
            finalString="${finalString}${this_char}"
            i=$((i+1))
        fi
    done
    # if you want to debug, uncomment the next 2 lines
    #finalpw=`cat $pwoutfile`
    #rm $outfile
    echo "$finalString"
} #make_8bitString

make_password()
{
    local length=$1
    local classes=$2

    local randompw=""
    local allclasses="lowerl upperl digit special eightbits"
    local selectedclasses=""
    local i=0

    # example assume classes=3, lenght=5
    if [ $classes = 0 ];then
        classes=1 # there is no such password that has no class at all
    fi
    while [ $i -lt $classes ]
    do
        number=$RANDOM
        let "number %= 5"
        number=$((number+1)) #get random number in [1,2,3,4,5]
        field=`echo $allclasses | cut -d" " -f$number`
        #rlLog "num[$number],field=[$field]"
        if  echo $selectedclasses| grep $field 2>&1 >/dev/null
        then
            continue
        else
            selectedclasses="$selectedclasses $field"
            i=$((i+1))
        fi
    done
    # up to here, we might have: selectedclasses= lowerl upperl special
    #i=$classes
    field="" #this is just a symble reuse, it has no relation with previous value
    while [ $i -lt $length ]
    do
        let "index = $i % $classes"
        index=$((index+1))
        field=`echo $selectedclasses | cut -d" " -f$index`
        selectedclasses="$selectedclasses $field"
        i=$((i+1))
    done
    echo "selectedclasses=[$selectedclasses]" >>/tmp/test.txt
    # up to here, we might have: selectedclasses= lowerl upperl special lowerl upperl
    #rlLog "selectedclasses=[$selectedclasses]"
    # it is possible length<class, in this case we have to fulfill length requirement
    i=0
    finalpw=""
    for class in $selectedclasses
    do
        if [ $i -lt $length ] ;then
            thischar=`echo_random $class` 
            finalpw="${finalpw}${thischar}"
            i=$((i+1))
        fi
    done
    echo "$finalpw"
} #make_password

echo_random()
{
    local class=$1
    local outf=$2
    local lowerl="a b c d e f g h i j k l m n o p q r s t u v w x y z"
    local upperl="A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    local digit="0 1 2 3 4 5 6 7 8 9"
    local special="= + . , ? ! / ~ @ # % ^"
    local eightbits="ť ú ů ý ž á č ď é ě í ň ó ř š å æ é ø ë ï ó ö ü ĉ ĝ ĥ ĵ ŝ ŭ ä å ö ù û ü ÿ à â ç é è ê ë ï î ô œ ä ö ü ß á é í ö ó ő æ þ ý í ɫ ŋ ʳ ɹ ɾ ʃ θ t̬ ð ʒ ʊ ʊ ɔ ɒ ɪ ɪ ɝ ɛ ɜ ɚ ə ə ʌ ɑ æ ø ą ć ę ł ń ż ź ś ô î ş ș ţ ț я ш е р т ы у и о п ю щ э ж ь л к й ч г ф д с а з х ц в б н м ¿ € ¢ £ ¥ ♥ ♦ ♠ ♣ • • ← ↑ → ↓ ✓ ♀ ♂ ☺ Δ ³ ² ¼ ½ ≥ ≤ ≠ ≈ ~ · ÷ × ± © ™ ® ° № § ∞ ‰ µ ø @ û ü ú ù ŵ ẅ ẃ ẁ ŷ ÿ ý ỳ ò ó ö ô ì í ï î è é ë ê à á ä â"

    #local special=". , ? < > / ( ) ~ ! @ # $ % ^ & * - + = _ { } [ ] ;"
    # FIXME: the special char: $ ( ) { } [ ] _ + - & * ; has special meaning in shell
    # this is due to 3 cause: 1. shell treats $? $! $@ differently
    #                         2. password will be fed into expect program, 
    #                            and ()[]{} are not welcomed
    #                         3. beaker doesn't like '<' and '>'
    local str=""
    local len=0
    local l
    if [ $class = "lowerl" ];then
        str="$lowerl"
        len=26
    fi
    if [ $class = "upperl" ];then
        str="$upperl"
        len=26
    fi
    if [ $class = "digit" ];then
        str="$digit"
        len=10
    fi
    if [ $class = "special" ];then
        str="$special"
        len=12 #full length should be 27
    fi
    if [ $class = "eightbits" ];then
        str="$eightbits"
        len=205 #full length should be 27
    fi
    index=$RANDOM
    let "index %= $len"
    index=$((index+1))
    l=`echo $str | cut -d" " -f$index`
    #rlLog "this letter: [${l}], index=[$index]"
    #echo -n "${l}" >> $outf 
    echo "${l}"
} #echo_random


make_ascii_string()
{
    #ipa file name may only include letters, numbers, _, -, .
    local length=$1
    if [ "$length" = "" ];then
        length=`getrandomint 1 255` #this is just a safe number
    fi
    local chars="a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    local len=0
    local string=""
    while [ "$len" -lt "$length" ]
    do
        index=`getrandomint 1 52`
        char=`echo $chars | cut -d" " -f$index`
        string="${string}${char}"
        len=$((len+1))
    done
    unset length
    unset len
    echo $string
} #GenerateFileName


