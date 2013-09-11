#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# new_dns_zone.sh - Create a new DNS zone for BIND.
# ---------------------------------------------------------------------------
#

#CONFIG


#This DNS Servers IP
serverip=127.0.0.1

#NS1
defaultns[1]=ns1.dnsserver.com
#NS2
defaultns[2]=ns2.dnsserver.com

#NS1IP
defaultnsip[1]=8.8.8.8
#NS2IP
defaultnsip[2]=8.8.4.4

namedconf="/etc/named.conf"
zonepath="/var/named/"

#Serial Format
serial=$(date +%s)

#END CONFIG


#MISC

zonepath=${zonepath%/}

#END MISC




#FUNCTIONS

NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)


function success()
{
	echo -e "$GREEN$*$NORMAL" >&2
}

function warning()
{
	echo -e "$YELLOW$*$NORMAL" >&2
}

function error()
{
	echo -e "$RED$*$NORMAL" >&2
	exit 1
}

function yesno
{
	read -n 1 -p "$1" -r REPLY
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo >&2
		echo "1";
	else
		echo >&2
		exit 1;
	fi
}

function reloadbind
{
	rndc reconfig
}

#END FUNCTIONS




#PROMPTS

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
	userroot=0
	warning "Script must be run with root permissions to save zone file!"
else
	userroot=1
fi

#Domain Name
read -p "Domain of New Zone: " primarydomain
#Primary IP
read -p "Primary IP of New Zone: " zoneip

#RNAME Field
read -p "SOA Email Address: " rname
rname=${rname/@/.}

#Get Mail Server Prefix
read -p "Primary MX Record Prefix (Default: mail): " mailprefix
mailprefix=${mailprefix:-mail}
#Get Mail Server IP
read -p "IP of Primary MX Record (Default: ${zoneip}): " mailip
mailip=${mailip:-${zoneip}}

	#SECTIONS TODO

		#Custom MX Records

		#Custom NS Records

#END PROMPTS


#TEMPORARY VARIABLES

zonename=${primarydomain}
zonefilename=${zonename}.zone
zonettl="86400"
soarefresh='1H'
soaretry='1M'
soaexpiry='1W'
soamaxcache='1D'
mxweight=0

#END TEMPORARY VARIABLES



#ZONE TEMPLATE

read -d '' zonetemplate << EOF
\$TTL            ${zonettl}
@       IN      SOA     ${defaultns[1]}.       ${rname}. (
                        ${serial}	; serial
                        ${soarefresh}	; slave refresh
                        ${soaretry}	; slave retry time in case of a problem
			${soaexpiry}	; slave expiry
                        ${soamaxcache} )	; maximum caching time in case of failed lookups
$(for i in "${defaultns[@]}"
	do
		echo  "@       IN      NS      ${i}."
	done
)
@       IN      A       ${zoneip}
@       IN      MX      ${mxweight}	${mailprefix}.${primarydomain}.
mail    IN      A       ${mailip}
www     IN      CNAME   ${primarydomain}.
EOF

#END ZONE TEMPLATE

#NAMED.CONF TEMPLATE

read -d '' namedconftemplate << EOF
zone \"${zonename}\" IN {
	type master;
	file \"${zonepath}/${zonefilename}\";
	allow-update { none; };
};
EOF

#END NAMED.CONF TEMPLATE

#DISPLAY NAMED.CONF

if [[ $(yesno "Do you want to preview zone file? [y/n]: ") ]]; then
	cat << EOF
#
#
#Zone File: ${zonepath}/${zonefilename}
#
#

$zonetemplate

EOF
fi

#END DISPLAY NAMED.CONF

#CREATE ZONE FILE

if [[ userroot -eq 0 ]]; then
	warning "Script is not running with root permission, so cannot save zone file and reload BIND! Exiting..."
	exit
else	
	if [[ $(yesno "Do you wish to create this zone file and add zone to named.conf? [y/n]: ") ]]; then
		warning "Creating Zone File and adding to BIND configuration."
		echo "$zonetemplate" > ${zonepath}/${zonefilename}
		echo "$namedconftemplate" >> $namedconf
		reloadbind
	fi
fi

#END CREATE ZONE FILE
