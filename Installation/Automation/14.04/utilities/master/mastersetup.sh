#!/bin/bash
set -u

os="ubuntu"
OS="Ubuntu"
OSVERSION="14.04"

repodir="/home/wynadmin/repository"
repository="TechSAPAC"
giturl="ssh://gitolite3@gitgs.wynyardgroup.com:443/${repository}"
gitdir="${repodir}/${repository}/Technical/Linux/${OS}/Installation/Automation/${OSVERSION}"

cgiusr="www-data"
cgigrp="admin"
wwwdir="/var/www"
cgidir="/var/www/cgi-bin/installations/${os}/${OSVERSION}"

echo '--------------------------------------------------------------------------------'
echo 'Instaling Git'
echo '--------------------------------------------------------------------------------'
sudo apt-get install -y git
sudo apt-get install -y tree

echo '--------------------------------------------------------------------------------'
echo 'Creating Git repository'
echo '--------------------------------------------------------------------------------'
rm -r -f ${repodir}/${repository}
cd ${repodir} && git init && git clone ${giturl}

echo '--------------------------------------------------------------------------------'
echo 'Installing Puppet Server ...'
echo 'See https://tickets.puppetlabs.com/browse/SERVER-528'
echo '--------------------------------------------------------------------------------'
sudo apt-get install -y puppetserver
sudo $(which puppet) resource service puppet ensure=stopped
sudo $(which puppet) resource service puppetserver ensure=stopped
sudo rm -r -f /etc/puppetlabs/puppet/ssl
sudo $(which puppet) cert list -a
sudo $(which puppet) master --no-daemonize --verbose

echo '--------------------------------------------------------------------------------'
echo 'Copying to /etc puppet module and manifets before starting puppet server'
echo '--------------------------------------------------------------------------------'
eval "sudo cp -r ${gitdir}/etc/* /etc/"

echo '--------------------------------------------------------------------------------'
echo 'Starting Puppet Server'
echo '--------------------------------------------------------------------------------'
sudo $(which puppet) resource service puppetserver ensure=running
sudo service puppetserver start


# IT looks if puppet hostname is defined in hosts, https://tickets.puppetlabs.com/browse/SERVER-528 
# seems to happen. Create the hosts records just before running puppet agent which look for puppet hostname.
echo '--------------------------------------------------------------------------------'
echo 'Run puppet agent to configure the master server itself ...'
echo '--------------------------------------------------------------------------------'
echo "192.96.102.150 puppet.wynyarddemo.local" | sudo tee -a /etc/hosts

sudo $(which puppet) cert sign --all
sudo $(which puppet) agent --test

echo '--------------------------------------------------------------------------------'
echo 'Copying Ubuntu auto installation start into HTTPD directories.'
echo '--------------------------------------------------------------------------------'
eval "sudo cp -r ${gitdir}/var/* /var/"
sudo chown -R ${cgiusr}:${cgigrp} ${wwwdir}
sudo find ${wwwdir} -type d -exec chmod ug+rwx {} \;
sudo find ${wwwdir} -type f -exec chmod ug+rw {} \;
eval "(cd ${cgidir} && sudo chmod ug+rwx *)"

echo 'Done'
