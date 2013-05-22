#!/bin/bash

# get top senders from mail queue
# and get top sender's domains from queue
function queue() {
        echo "------------------------------------------"
        echo "|       Current queue top senders:       |"
        echo "------------------------------------------"
        /usr/sbin/exiqgrep -b| awk '{print $3}'| grep -v "<>" |awk -F"<" '{print $2}' | awk -F">" '{print $1}'| sort | uniq -c | sort -nr | head 
	echo ""
        echo "------------------------------------------"
        echo "|  Current queue top sender's domains:   |"
        echo "------------------------------------------"
	/usr/sbin/exiqgrep -b | awk '{print $3}'| awk -F"@" '{print $2}'| sed -e 's/>//'| grep . |sort | uniq -c| sort -nr | head 
}

# get top senders from mainlog for current date
function sendlist() {
        echo "------------------------------------------"
        echo "|           Today top senders:           |"
        echo "------------------------------------------"
        grep "<=" /var/log/exim_mainlog | grep `date +%F`  | awk '{print $5}'| grep -v "<>" | sort | uniq -c | sort -rn| head
	echo ""
        echo "------------------------------------------"
        echo "|      Today top sender's domains:       |"
        echo "------------------------------------------"
	grep "<=" /var/log/exim_mainlog | grep `date +%F`  | awk '{print $5}'| grep -v "<>" | awk -F"@" '{print $2}' | sort | uniq -c | sort -rn| head
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

# get message id by domain
function maillist_dom() {
        local DOMAIN=$1;
        if [[ $DOMAIN =~ ^[0-9a-zA-Z.-]+$ ]]; then
                /usr/sbin/exiqgrep -bf $DOMAIN;
        else
                echo "wrong domain"
        fi
}

# get frozen messages
function frozenlist() {
                /usr/sbin/exiqgrep -bz 
}

# get bounce messages
function bouncelist() {
                /usr/sbin/exiqgrep -bf "<>"
}


# get message body by id
function body() {
        local ID=$1
        if [[ $ID =~ ^[0-9a-zA-Z]{6}-[0-9a-zA-Z]{6}-[0-9a-zA-Z]{2}$ ]]; then
                /usr/sbin/exim -Mvb $ID
		echo "";
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

# remove messages by domain
function remove_dom() {
        local DOMAIN=$1;
        if [[ $DOMAIN =~ ^[0-9a-zA-Z.-]+$ ]]; then
                /usr/sbin/exiqgrep -if $DOMAIN | xargs /usr/sbin/exim -Mrm | wc -l;
        else
                echo "wrong domain"
        fi
}



# remove frozen
function remove_frozen() {
	echo "Removed frozen messages: `/usr/sbin/exiqgrep -iz | xargs /usr/sbin/exim -Mrm 2>/dev/null| wc -l`"
}

# remove bounces
function remove_bounce() {
        echo "Removed bounces: `/usr/sbin/exiqgrep -if \"<>\" | xargs /usr/sbin/exim -Mrm 2>/dev/null| wc -l`"
}

# help
function help() {
        echo "Usage: sendlist.sh COMMAND"
        echo "          -q:			show top senders and their domains from mail queue"
        echo "          -s:			show top today senders and their domains from exim mainlog"
        echo "          -m sender_address:	show messages in queue from sender_address"
        echo "          -md sender_domain:	show messages in queue from sender_domain"
	echo "          -mz:			show frozen messages in queue"
	echo "          -mb:			show bounce messages in queue"
        echo "          -b message_id:	show message body with message_id"
        echo "          -h message_id:	show message header with message_id"
	echo "          -bh message_id:	show full message with message_id"
        echo "          -r sender_address:	remove mail from queue from sender_address, return number of removed messages"
	echo "          -rd sender_domain:	remove mail from queue from domain, return number of removed messages"
	echo "          -rz:			remove frozen messages"
	echo "          -rb:			remove bounce messages"
        echo "          --help:		show this help"
}

## main()

case "$1" in
-q)
        queue
        ;;
-m)
        maillist $2
        ;;
-md)
	maillist_dom $2
	;;
-mz)
	frozenlist
	;;
-mb)
	bouncelist
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
-rd)
        remove_dom $2
        ;;
-rz)
	remove_frozen
	;; 
-rb)
        remove_bounce
        ;;
--help)
        help
        ;;
*)
        help
        ;;
esac

