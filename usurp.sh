#!/bin/bash
#vars
PYTHONPATH='/Library/Frameworks/Python.framework/Versions/3.4'
FILE1=''
FILE2=''

#functions
file_extract (){
    #1st is smaller file to be moved to second
    extract="Only in "
    exlen=${#extract}
    
    if [ $# -ne 3 ]; then
        echo "insufficient arguments! Ending program..."
        sleep .7s
        return 1
    else
        #first argument is a file that contains pathnames, but needs to be altered
        #second is root directory, relevant to $1 file
        #third is path to directory where files will be transferred

        while read -r line
        do
            LINE=${line:$exlen}
            LINE=${LINE//: /\/}
            echo "moving $LINE to $3"

            mv $LINE $3
        done < $1      
    mv $2 ~/.Trash 
    fi
    return 0
}

check_file (){
    retval=0
    echo "Again, for function $0: " 
    echo "you entered $1 and $2"
    sleep 1s
    if [ $# -ne 2 ]; then
        echo "incorrect number of arguments"
        retval=1
    else
#-----------------EDIT ACCORDING TO POTENTIAL CURRENT DIRECTORY-------------#
#-------currently in ~/Pictures -------------#
	pwd="~/Pictures"
        fi1="$1"
        fi2="$2"
        
	echo " searching for: $1 "
        echo " and $2 "
	sleep .5s
        if [[ -d "$fi1" && -d "$fi2" ]]; then
            retval=0
            FILE1=$fi1
            FILE2=$fi2
	    echo "files found!"
        else
            echo "cannot locate files, or files do no exist"
            retval=1
        fi
    fi
    return $retval
}

if [ "$#" -ne 2 ]; then
    COMPLETE=1 #false, 0 true
    END="x"
    while [ $COMPLETE -eq 1 ]; do         
        read -a FI -p "Please enter files you wish to compare and usurp ('x' to exit): " 
        if [ ${FI[0]} ==  "x" ]; then
            exit 0
        elif [ ${#FI[@]} -ne 2 ]; then 
	     echo "incorrect number of args"
        else
            check_file $FI[0] $FI[1]
            if [ $? -eq 0 ]; then
                COMPLETE=0
            fi
        fi
    done
else
    echo "YOU ENTERED $1 $2"
    check_file "$1" "$2"
    if [ $? -eq 0 ]; then
        echo "files provided are good"
        COMPLETE=0
    else
        echo "files are not good"
        echo "exiting program..."
        sleep .7s
        exit 1
    fi
fi

if [ $COMPLETE -eq 0 ]; then
    #divide and conquer
    INFO="collected.txt"
    F1="first.txt"
    F2="second.txt"
    #create temp files
    touch $F2 $F1 $INFO
    
    #read file and isolate unique incidences of each file within directory
    echo "comparing $FILE1 and $FILE2 now..."
    sleep 2s
    diff -rq "$FILE1" "$FILE2" | grep "Only" > "$INFO"
    old_IFS=$IFS
    #remove .whatever from files
    S1="$( cut -d '.' -f 1 <<< "$FILE1" )"
    S2="$( cut -d '.' -f 1 <<< "$FILE2" )"
    COUNT1=0
    COUNT2=0
#-----------------------IMPORTANT---------------------------
# change values. only files ending in these will be accounted for and moved. 
# everything else will be ignored
    m=( "jpg" "jpeg" "JPEG" "mov" "MOV" "avi" "png" "PNG" "gif" "GIF" )
    #divides everything with '|'
    media=$( printf "|%s" ${m[@]} )
    media="${media:1}" #removes '|' at the beginning
    
    #seperate "Only in..." lines into seperate files based on location
    #FILE1 info in F1, FILE2 info in F2
    while read -r line 
    do
	LINE=$line
	echo "$LINE" | egrep --quiet "\.(${media})$"
	if [ $? -eq 0 ] && [[ $line == "Only in "$S1" " ]]; then
	    echo "Exclusive file in "$S1"..."
	    echo ${line:$exlen} >> $F1
	    COUNT1=$(($COUNT1 + 1))
        elif [ $? -eq 0 ] && [[ $line == "Only in "$S2" " ]]; then
            echo "Exclusive file in "$S2"..."
            echo ${line:$exlen} >> $F2
            $COUNT2=$(($COUNT2 + 1))
        else
            echo "Not a media file!"
        fi
        sleep .5s
    done < $INFO
        #finished

    if [ $COUNT1 -gt $COUNT2 ]; then
        echo "$S1 is larger than $S2"
        file_extract $F1 $FILE1 $FILE2
    else
        echo "$S2 is larger than $S1"
        file_extract $F2 $FILE2 $FILE1
    fi

    if [ $? -eq 0 ];then
        echo "Program sucessfully ended"
        sleep .5s
        echo "Ended..."
        exit 0
    else
        echo "Program ended abnormally"
        sleep .7s
        echo "Ended..."
        exit 1
    fi
else #COMPLETE did not pass -> program cannot continue sucessfully 
    echo "Program cannot complete sucessfully"
    sleep .7s
    echo "Endind..."
    exit 1
fi
