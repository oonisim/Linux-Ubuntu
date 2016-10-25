#!/bin/bash
set -u -e
#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10 JUL 2016 initial for Ubuntu 14.04
#--------------------------------------------------------------------------------
# [Function] 
#     Generate post Ubuntu installation script.
#     Preseeding (plus kickstart) focuses on Ubuntu OS generic installation.
#     Post configuration script handles site specific configurations.
#     Do NOT mix them up and place clear separation and isolation.
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
# CGI content type
#--------------------------------------------------------------------------------
echo -e "Content-type: text/plain\n\n"

#--------------------------------------------------------------------------------
# Bash options for the generated shell script content
#--------------------------------------------------------------------------------
echo -e "set -u -e -x"

#--------------------------------------------------------------------------------
# Load the host configuration of the host being installed, then the site property.
# The site property depends host configuration information.
#--------------------------------------------------------------------------------
. ./_loadHostConfig.sh
. ./properties/site.properties

#--------------------------------------------------------------------------------
# Network Interface (Proxy)
#--------------------------------------------------------------------------------
while read line
do
    eval echo -e "$line"
done < "./templates/proxy.template"
echo -e "\n"

#--------------------------------------------------------------------------------
# Reconfigure hostname/network/DNS (they are inter-related)
# Does NOT work ...
#--------------------------------------------------------------------------------
if false
then
	echo "ifdown ${INTERFACE}"
	echo "dhclient -r -x"
	echo "pkill dhclient"

	echo "hostnamectl set-hostname ${HOSTNAME}.${DNS_SEARCH}"
	echo "echo '${ADDRESS} ${HOSTNAME}.${DNS_SEARCH} ${target}' > /etc/hosts" 
	echo "echo 'nameserver ${DNS_HOST}'> /etc/resolv.conf"

	echo "cat << HOGEHOGE > /etc/network/interfaces"
	while read line
	do
		eval echo "$line"
	done < "./templates/interfaces.template"
	echo "HOGEHOGE"
	echo -e "\n"

	echo "ifup ${INTERFACE}"
	echo -e "\n"
fi
	
#--------------------------------------------------------------------------------
# Disk partition
#--------------------------------------------------------------------------------
cat ./templates/partition.template
echo -e "\n"

#--------------------------------------------------------------------------------
# Puppet
#--------------------------------------------------------------------------------
while read line
do
    eval echo -e "$line"
done < "./templates/puppet.template"
echo -e "\n"

echo "# NOINTERNET=${NOINTERNET}"
