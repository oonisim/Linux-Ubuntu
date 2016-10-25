#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial for Ubuntu 14.04
#--------------------------------------------------------------------------------
# [Function]
# Puppet NTP Server configuration
#
# [Dependencies]
# https://forge.puppet.com/puppetlabs/ntp
#--------------------------------------------------------------------------------
class site_ntp::server (
  $driftfile='/var/lib/ntp/ntp.drift',
  $logfile='/var/log/ntpd.log'
){
    class { 'ntp':
        servers         => ['127.127.1.0',],
        fudge           => ['127.127.1.0 stratum 10',],
        #udlc_stratum    => '10',
        restrict        => [
            "${::network} mask ${::netmask} nomodify notrap",
            '-4 default kod notrap nomodify nopeer noquery',
            '-6 default kod notrap nomodify nopeer noquery',
            '127.0.0.1',
            '-6 ::1',
            '::1',
        ],
        #broadcastclient => true,
        driftfile  => $driftfile,
        logfile    => $logfile,
    }
}
