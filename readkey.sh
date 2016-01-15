#!/bin/bash

int_handler() {
    echo -e "\r\x1b[K*INT*"
}

restore_tty() {
    stty sane
    echo -e " \r\nFinished"
}

trap int_handler INT
trap restore_tty EXIT
stty -echo
loop="1"
spinner="-"
esc=$(echo -ne '\x1b') 
escseq="" 
key=""
while [ "$loop" = "1" ]
do
    case $spinner in
	'/')
	    spinner='-'
	    ;;
	'-')
	    spinner='\\'
	    ;;
	'\\')
	    spinner='|'
	    ;;
	'|')
	    spinner='/'
	    ;;
    esac
    IFS="" read -r -N 1 -t 0.1 -s key
    if [ -n "$key" ] 
    then
	if [ -n "$escseq" ] 
	then
	    if [ "$key" = "$esc" ] 
	    then
		if [ -n "$escseq" ] 
		then
		    echo -n "$escseq" | od -A none -tx1c
		    if [ "$escseq" = "$esc" ]
		    then
			loop=0
		    fi
		fi
		escseq="$esc"
	    else
		escseq="${escseq}${key}" 
	    fi
	else
	    if [ "$key" = "$esc" ] 
	    then
		escseq="$esc" 
	    else
		echo -n "$key" | od -A none -tx1c | tr -d '\n' ; echo
	    fi 
	fi 
    else
	if [ -n "$escseq" ] 
	then
	    echo -n "$escseq" | od -A none -tx1c
	    if [ "$escseq" = "$esc" ] 
	    then loop=0 
	    fi 
	    escseq="" 
	else
	    echo -ne "${spinner}\b" 
	fi 
    fi
done
