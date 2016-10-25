#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial for Ubuntu 14.04
#--------------------------------------------------------------------------------
# [Function]
# Puppet NTP client configuration
#
# [Dependencies]
# https://forge.puppet.com/puppetlabs/ntp
#--------------------------------------------------------------------------------    
class site_ntp::client (
  $ntp_server, $driftfile='/var/lib/ntp/drift'
){
    if($ntp_server == undef){
        fail("ntp_server is not defined")
    }
    class { 'ntp':
        servers         => ["${ntp_server}"],
        restrict        => ["${ntp_server} mask ${::netmask} nomodify notrap noquery"],
        driftfile       => $driftfile
    }
}

