#!/bin/bash

# get top senders from mail queue
function queue() {
        echo "------------------------------------------"
        echo "|       Current queue top senders:       |"
        echo "------------------------------------------"
        /usr/sbin/exiqgrep -b| awk '{print $3}'| grep -v "<>" |awk -F"<" '{print $2}' | awk -F">" '{print $1}'| sort | uniq -c | sort -nr | head -n20
}

# get top senders from mainlog for current date
function sendlist() {
        echo "------------------------------------------"
        echo "|           Today top senders:           |"
        echo "------------------------------------------"
        grep "<=" /var/log/exim_mainlog | grep `date +%F`  | awk '{print $5}'| grep -v "<>" | sort | uniq -c | sort -rn| head -n20
}

# get message id by sender
function maillist() {
        local SENDER=$1;
        if [[ $SENDER =~ ^[_0-9a-zA-Z.-]+@[0-9a-zA-Z.-]+$ ]]; then
                /usr/sbin/exiqgrep -bf $SENDER;
        else
                echo "wrong mail address"
        fi
}

# get message body by id
function body() {
        local ID=$1
        if [[ $ID =~ ^[0-9a-zA-Z]{6}-[0-9a-zA-Z]{6}-[0-9a-zA-Z]{2}$ ]]; then
                /usr/sbin/exim -Mvb $ID
		echo "---------------------------------------------------------------";
		echo "body hash: `/usr/sbin/exim -Mvb $ID | md5sum| awk '{print $1}'`";
        else
                echo "Wrong message id"
        fi
}

# get message header by id
function header() {
        local ID=$1
        if [[ $ID =~ ^[0-9a-zA-Z]{6}-[0-9a-zA-Z]{6}-[0-9a-zA-Z]{2}$ ]]; then
                /usr/sbin/exim -Mvh $ID
        else
                echo "Wrong message id"
        fi
}

# remove messages by sender
function remove() {
        local SENDER=$1;
        if [[ $SENDER =~ ^[_0-9a-zA-Z.-]+@[0-9a-zA-Z.-]+$ ]]; then
                /usr/sbin/exiqgrep -if $SENDER | xargs /usr/sbin/exim -Mrm | wc -l;
        else
                echo "wrong mail address"
        fi
}

# help
function help() {
        echo "Usage: sendlist.sh COMMAND"
        echo "          -q: show top senders from mail queue"
        echo "          -s: show top today senders from exim mainlog"
        echo "          -m sender_address: show messages in queue from sender_address"
        echo "          -b message_id: show message body with message_id"
        echo "          -h message_id: show message header with message_id"
	echo "          -bh message_id: show full message with message_id"
        echo "          -r sender_address: remove mail from queue from sender_address, return number of removed messages"
        echo "          --help: show this help"
}

## main()

case "$1" in
-q)
        queue
        ;;
-m)
        maillist $2
        ;;
-s)
        sendlist
        ;;
-h)
        header $2
        ;;
-b)
        body $2
        ;;
-bh)
	header $2
	body $2
	;;
-r)
        remove $2
        ;;
--help)
        help
        ;;
*)
        help
        ;;
esac

