#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# new_dns_zone.sh - Create a new DNS zone for BIND.
# Usage: dns.sh [-h|--help]
# Revision history:
# 2013-09-06    Created by new_script.sh ver. 3.0
# ---------------------------------------------------------------------------
#


#
#CONFIG
#

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


#
#END CONFIG
#

#Prompts

echo "Warning: Script must be run with root permissions!"

#Domain Name
read -p "Domain of New Zone: " primarydomain
#Primary IP
read -p "Primary IP of New Zone: " zoneip

#RNAME Field
read -p "SOA Email Address: " rname
rname=${rname/@/.}

#MX Record Loop

#Get Mail Server Prefix
read -p "Primary MX Record Prefix (Default: mail): " mailprefix
mailprefix=${mailprefix:-mail}
#Get Mail Server IP
read -p "IP of Primary MX Record (Default: ${zoneip}): " mailip
mailip=${mailip:-${zoneip}}

#End MX Record Loop

#Start Name Server Loop

#Prompt: Default or Custom Nameservers, Default is $NS1 and $NS2, custom has $Primary IP appended to end of it, dont end with dot

#Custom Name Server 1: (Enter First Nameserver prefix)

#Start Custom NS Loop (End if = '' or if Loop Count > $NSCount - 1 )

#Increment Loop Count

#Custom Name Server x: (Enter $x Nameserver Prefix or press ENTER to continue)

#End Custom NS Loop

#If Name Server x ends with $Primary Domain

#END Name Server Loop





#
#TEMPORARY VARIABLES
#

displayzone=1
createzone=0
displaynamedconf=1
zonename=${primarydomain}
zonefilename=${zonename}.zone

#
#END TEMPORARY VARIABLES
#


#Zone Template

read -d '' zonetemplate << EOF
\$TTL            86400
@       IN      SOA     ${defaultns[1]}.       ${rname}. (
                        ${serial}	; serial
                        1H	; refresh
                        1M	; retry
			1W	; expiry
                        1D )	; minutes
$(for i in "${defaultns[@]}"
	do
		echo  "@       IN      NS      ${i}."
	done
)
@       IN      A       ${zoneip}
@       IN      MX      10	${mailprefix}.${primarydomain}.
mail    IN      A       ${mailip}
www     IN      CNAME   ${primarydomain}.
EOF


#named.conf Template

read -d '' namedconftemplate << EOF
zone \"${zonename}\" IN {
	type master;
	file \"${zonepath}/${zonefilename}\";
	allow-update { none; };
};
EOF



#Display Template

if [ "$displayzone" -eq 1 ]; then
	cat << EOF
#
#
#Zone File: ${zonepath}/${zonefilename}
#
#

$zonetemplate

EOF
fi


#Display named.conf Template

if [ "$displaynamedconf" -eq 1 ]; then
	cat << EOF
#
#
#${namedconf}
#
#

$namedconftemplate"

EOF
fi

#Add Zone File to BIND config

if [ "$createzone" -eq 1 ]; then
	echo "Creating Zone File and adding to BIND configuration."
	echo "$zonetemplate" > ${zonepath}/${zonefilename}
	echo "$namedconftemplate" >> $namedconf

fi
