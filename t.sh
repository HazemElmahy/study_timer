#!/bin/bash

## COLOR VARIABLES{{{
RED='\033[0;31m'
#}}}

function break_timer() {
    # RECORDING STUYING TIME IN ~/timer/folder{{{
    TODAY=$(date +%y-%m-%d)
    TODAY_FOLDER=~/timer/$TODAY
    mkdir -p $TODAY_FOLDER
    break_i=1
    if [[ -e $TODAY_FOLDER/${break_i}_b ]] ; then
        while [[ -e $TODAY_FOLDER/${break_i}_b ]] ; do
            let break_i++
        done
    fi
    CURRENT="$TODAY_FOLDER/${break_i}_b"
    touch $CURRENT
    echo start: `date +%H:%M:%S` >> $CURRENT
    trap 'echo end: `date +%H:%M:%S` >> $CURRENT' EXIT
    #}}}
    date1=$((`date +%s` + $SEC * 60));

    # SOME INITIAL ECHO-ING{{{
    echo Break number $break_i today:$TODAY
    echo "timer is set for" `expr $SEC` "mins"

    while [ "$date1" -ge `date +%s`  ]; do 
        echo -ne "$(date -u --date @$(($date1 - `date +%s` )) +%H:%M:%S)\r"; 

    done

    
    notify-send -u critical "Break session number $break_i today:$TODAY is finished" "It was $SEC minutes" -i sand-watch.svg
    mpg123 -q $MUS_DIR/$MUS
}

function onExit() {
    now=$(date +%s)
    now_date=$(date +%H:%M:%S)
    current_total=$(( $now - $1 ))
    total=$(($current_total + $3))
    total_date=$(date -u -d@$(($total)) +"%H:%M:%S")

    echo -e "\n\ntotal studying time today: $total_date"
    echo "end: $now_date" >> $2
    echo "total: $total" >> $2

}


function timer() {
    for pid in $(pidof -x t.sh);
    do
        if [ $pid != $$ ]; then
            echo "timer is already running with PID $pid"
            exit 1
        fi
    done

    # RECORDING STUYING TIME IN ~/timer/folder{{{
    TODAY=$(date +%y-%m-%d)
    TODAY_FOLDER=~/timer/$TODAY
    mkdir -p $TODAY_FOLDER
    study_i=1
    if [[ -e $TODAY_FOLDER/$study_i ]] ; then
        while [[ -e $TODAY_FOLDER/$study_i ]] ; do
            let study_i++
        done
    fi

    if [ $study_i -gt 1 ];
    then
        prev=$TODAY_FOLDER/$(( $study_i - 1 ))
        total=$(cat $prev | awk 'END{print $2}')
    else
        total=0
    fi

    CURRENT=$TODAY_FOLDER/$study_i
    touch $CURRENT
    start=$(date +%s)
    echo start: `date +%H:%M:%S` >> $CURRENT
    # trap 'echo end: `date +%H:%M:%S` >> $CURRENT' EXIT
    trap 'onExit "$start" "$CURRENT" "$total"' EXIT
    #}}}
    date1=$((`date +%s` + $SEC * 60));
    TC='\033[1;31m'
    NC='\033[0m'

    # SOME INITIAL ECHO-ING{{{
    echo Studying session number $study_i today:$TODAY
    echo "timer is set for" `expr $SEC` "mins"
    echo 'Press "b" to take a break'
    # echo "Timer song is $MUS"
    #}}}

    for ((i=$SEC*60;i>=0;i--)); 
    do 
        printf "\r${TC}$(date -u -d@$(($i)) +"%H:%M:%S")\r${NC}"

        # echo  "$(date -u --date @$(($date1 - `date +%s` )) +%H:%M:%S)\r";
        read -t 1 -n 1 -s key



        if [ "$key" = 'b' ];
        then
            printf "${TC}$(date -u -d@$(($i)) +"%H:%M:%S")${NC} \n"
            echo -e "Break time press any key to resume...\r"
            read -n 1 -s
        fi

    done

    
    notify-send -u critical "Studying session number $study_i today:$TODAY is finished" "It was $SEC minutes" -i sand-watch.svg
    mpg123 -q $MUS_DIR/$MUS
}

## HELP WITH -h{{{
function helper() {

    echo -e "
    This is a simple studying session timer I made for myself

        -t minutes     to start timer ends in Seconds
            >> You will be able to suspend the timer to take a break by pressing 'b'
            .. then you can resume by pressing any key.
        -m music_file_name      
            file should be in /home/hazem/Music/music
            default is cat_mario_field.mp3
            THIS SHOULD BE USED BEFORE -s
        -h              shows this help menu
    "
}
#}}}

MUS="Opa_Tsupa/Veiculo.mp3"
MUS_DIR=/home/hazem/Music

## FLAGS{{{

while getopts t:b:hm: flag
do
    case "${flag}" in
        h) helper;;
        m) MUS=${OPTARG};;
        t)
            SEC=${OPTARG}
            timer;;
        b) 
            SEC=${OPTARG}
            break_timer;;
        *) echo -e "Use '-h' to see how to use Haze Timer"
    esac
done

if [ $OPTIND -eq 1 ]; then echo -e "Welcome to study timer\nNo options were passed try -h to get help"; fi

#}}}
