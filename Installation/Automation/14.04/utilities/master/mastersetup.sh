#!/bin/bash
set -u

#--------------------------------------------------------------------------------
# Make sure that name resolution is available to resolve github, etc.
#--------------------------------------------------------------------------------

os="ubuntu"
OS="Ubuntu"
OSVERSION="14.04"

repodir="/home/wynadmin/repository"
repository="Linux-Ubuntu"
giturl="https://github.com/oonisim/${repository}.git"
gitdir="${repodir}/${repository}/Installation/Automation/${OSVERSION}"

cgiusr="www-data"
cgigrp="wynadmin"
wwwdir="/var/www"
cgidir="/var/www/cgi-bin/installations/${os}/${OSVERSION}"

puppet="/opt/puppetlabs/puppet/bin/puppet"

echo '--------------------------------------------------------------------------------'
echo 'Instaling Git'
echo '--------------------------------------------------------------------------------'
sudo apt-get install -y git
sudo apt-get install -y tree

echo '--------------------------------------------------------------------------------'
echo 'Creating Git repository'
echo '--------------------------------------------------------------------------------'
rm -r -f ${repodir}
mkdir ${repodir}
cd ${repodir} && git init && git clone ${giturl}


echo '--------------------------------------------------------------------------------'
echo ' Setting up Puppet repository ...'
echo ' Disable this when using no internet environment'
echo '--------------------------------------------------------------------------------'
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
sudo dpkg -i puppetlabs-release-pc1-trusty.deb

echo '--------------------------------------------------------------------------------'
echo 'Installing Puppet Server ...'
echo 'See https://tickets.puppetlabs.com/browse/SERVER-528'
echo '--------------------------------------------------------------------------------'
sudo apt-get update
sudo apt-get install -y puppetserver
sudo ${puppet} resource service puppet ensure=stopped
sudo ${puppet} resource service puppetserver ensure=stopped
sudo rm -r -f /etc/puppetlabs/puppet/ssl
sudo ${puppet} cert list -a
sudo ${puppet} master --no-daemonize --verbose

echo '--------------------------------------------------------------------------------'
echo 'Copying to /etc puppet module and manifets before starting puppet server'
echo '--------------------------------------------------------------------------------'
eval "sudo cp -r ${gitdir}/etc/* /etc/"

echo '--------------------------------------------------------------------------------'
echo 'Starting Puppet Server'
echo ' If you see "Notice: Starting Puppet master version xxx", press CTRL-C.'
echo '--------------------------------------------------------------------------------'
sudo ${puppet} resource service puppetserver ensure=running
sudo service puppetserver start


# IT looks if puppet hostname is defined in hosts, https://tickets.puppetlabs.com/browse/SERVER-528 
# seems to happen. Create the hosts records just before running puppet agent which look for puppet hostname.
echo '--------------------------------------------------------------------------------'
echo 'Run puppet agent to configure the master server itself ...'
echo '--------------------------------------------------------------------------------'
echo "143.96.102.150 puppet.demo.local" | sudo tee -a /etc/hosts

sudo ${puppet} cert sign --all
sudo ${puppet} agent --test

echo '--------------------------------------------------------------------------------'
echo 'Copying Ubuntu auto installation start into HTTPD directories.'
echo '--------------------------------------------------------------------------------'
eval "sudo cp -r ${gitdir}/var/* /var/"
sudo chown -R ${cgiusr}:${cgigrp} ${wwwdir}
sudo find ${wwwdir} -type d -exec chmod ug+rwx {} \;
sudo find ${wwwdir} -type f -exec chmod ug+rw {} \;
eval "(cd ${cgidir} && sudo chmod ug+rwx *)"

echo 'Done'