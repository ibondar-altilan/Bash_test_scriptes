#! /bin/bash
#
############################## PING TEST SCRIPT ##############################
# 
# syntax: ping_test.sh [ -t IPv#] [ -f filename] [ IPaddr1 IPaddr2 ... IPaddrN ]
# hostnames are resolving with the command dig (IPv4 only)
# -t parameter must be "IPv4" or "IPv6", if it omitted - IPv4 by default
# filename has one line per host, several -f option are possible
#
# Exit errors status:
# 1 - invalid options
# 2 - IP addresses or file are missing
#
IPver="4" # set default value to IPv4
filename_IPaddr="" # filename with IP adresses is empty by default
#
while getopts :t:f: opt
do
    case $opt in
	t) # Found -t option
	    if [ $OPTARG = "IPv4" ]
	    then
                IPver="4"
	    elif [ $OPTARG = "IPv6" ]
	    then
		IPver="6"
	    else
		echo "Usage: -t IPv4 or -t IPv6"
		echo "Exiting script..."
		exit 1 #invalid options
		##############################
	    fi
	    ;;
	f) # Found -f option
            if ! [ -f $OPTARG ]
	       then
		echo "$OPTARG is not a valid file"
	        echo "Exiting script..."
	        exit  1 # invalid options
		##############################
	    elif [ -r $OPTARG ] && [ -s $OPTARG ]
		 # check if filename is readable and non empty
	    then
		filename_IPaddr=$OPTARG
		echo "Using address(es) from $filename_IPaddr"
		addr_list="$addr_list $(cat $filename_IPaddr)"
	    else
 	        echo "Warning: file with IP addresses is empty or unreadable"
                echo
	    fi
	    ;;	
	*)  echo "Usage: -t IPv4 or -t IPv6 or -f filename"
	    echo "Exiting script..."
	    exit  1 # invalid options
	    ##############################
	    ;;
    esac
done
shift $[ $OPTIND - 1 ]
# concatenate addresses from file and position parameters 
addr_list="$addr_list $*"
#
# check if valid IP adresses for ping are
if [ "$addr_list" = ' ' ] # params list is empty
then
    echo "IP adress(es) for ping are missing"    echo "Exiting script..."
    exit 2 # addresses are missing
    ##############################
fi
echo
# do ping
for ip in $addr_list
do
    echo "Ping of hostname: $ip"
    ping -q"$IPver"c 1 $(dig $ip +short)
    echo
done
