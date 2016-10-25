#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial.
#--------------------------------------------------------------------------------
# [Function]
# Windows IIS configurations.
#
# [Dependencies]
# https://forge.puppet.com/puppetlabs/windows
#--------------------------------------------------------------------------------
class site_windows::iis
{    windowsfeature { [
            'Application-Server',
            'AS-Web-Support', 
            'AS-HTTP-Activation',
            'AS-TCP-Activation',
            'NET-HTTP-Activation',
            'NET-WCF-TCP-Activation', 
            'NET-Framework-45-ASPNET',
            'Web-Server',
            'Web-WebServer',
            'Web-Common-Http', 
            'Web-Mgmt-Console',
            'Web-Scripting-Tools',
            'Web-Mgmt-Service',
            'OOB-WSUS'
        ]: 
        ensure => present 
    }
}
