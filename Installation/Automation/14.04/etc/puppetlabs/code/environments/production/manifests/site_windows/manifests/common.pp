#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial
#--------------------------------------------------------------------------------
# [Function]
# Windows common miscellaneous configurations.
#
# [Dependencies]
# https://forge.puppet.com/puppetlabs/windows
# chocolatey.org
#--------------------------------------------------------------------------------
class site_windows::common
{
    windowsfeature { [
           'Telnet-Client',
           'PowerShell-ISE'
        ]: 
        ensure => present 
    }

    #--------------------------------------------------------------------------------
    # Utilities
    #--------------------------------------------------------------------------------
    package { [
            'putty',
             'jdk8',
             'python',
             'winscp',
             'sysinternals'
        ]:
        ensure   => installed,
        require  => Class['chocolatey']
    }
}
