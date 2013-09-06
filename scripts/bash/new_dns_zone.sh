#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# new_dns_zone.sh - Create a new DNS zone for BIND.
# Usage: dns.sh [-h|--help]
# Revision history:
# 2013-09-06    Created by new_script.sh ver. 3.0
# ---------------------------------------------------------------------------
#
#Settings/Get

#DNS Server IP
serverip=127.0.0.1
#NSCount
nscount=2
#NS1
ns1=ns1.dnsserver.com
#NS2
ns2=ns2.dnsserver.com
#Additional Default Nameservers
#ns3=
#ns4=

#NS1IP
ns1ip=8.8.8.8
#NS2IP
ns2ip=8.8.4.4
#Additional NS IPs
#ns3ip=
#ns4ip=

#
#Create New Zone File

#Prompts

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

#Serial
serial=$(date +%s)


#Echo Template

cat << EOF

\$TTL            86400
@       IN      SOA     ${ns1}.       ${rname}. (
                        ${serial}	; serial
                        1H	; refresh
                        1M	; retry
			1W	; expiry
                        1D )	; minutes
@       IN      NS      ${ns1}.
@       IN      NS      ${ns2}.
@       IN      A       ${zoneip}
@       IN      MX      10	${mailprefix}.${primarydomain}.
mail    IN      A       ${mailip}
www     IN      CNAME   ${primarydomain}.
EOF



#Add Zone File to BIND config
