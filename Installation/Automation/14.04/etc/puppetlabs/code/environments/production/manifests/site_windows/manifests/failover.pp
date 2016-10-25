#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial.
#--------------------------------------------------------------------------------
# [Function]
# Windows Failover Cluster Feature and Tools Features
#
# [Dependencies]
# https://forge.puppet.com/puppetlabs/windows
#--------------------------------------------------------------------------------
class site_windows::failover {
    windowsfeature { [
            'Failover-Clustering',
            'RSAT-Clustering-Mgmt', 
            'RSAT-Clustering-PowerShell', 
            'RSAT-Clustering-AutomationServer', 
            'RSAT-Clustering-CmdInterface'
        ]: 
        ensure => present 
    }
}