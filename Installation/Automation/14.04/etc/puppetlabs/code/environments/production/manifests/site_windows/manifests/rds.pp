#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial
#--------------------------------------------------------------------------------
# [Function]
# Windows Remote Desktop configurations.
#
# [Dependencies]
# https://forge.puppet.com/puppetlabs/windows
#--------------------------------------------------------------------------------
class site_windows::rds
{    windowsfeature { [
            'Remote-Desktop-Services',
            'RDS-RD-Server',
            'RDS-Licensing'
        ]: 
        ensure => present 
    }
}
