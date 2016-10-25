#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial.
#--------------------------------------------------------------------------------
# [Function]
# Puppet Windows domain controller configuration.
#
# [Dependencies]
# https://forge.puppet.com/puppetlabs/windows
#--------------------------------------------------------------------------------
class site_windows::dc (
    $domainName='YOUNEEDTOCHANGE!!',
    $domainHost
){
    $isReadyToBeDC = join( [
        'if( ',
            '((Get-WindowsFeature | Where-Object {$_.Name -eq "AD-Domain-Services"}).InstallState -eq "Installed") ',
            '-and ',
#            "((Get-ADDomainController -Identity '${domainHost}').Domain -ne '${domainName}' ) ",
            '((gwmi win32_computersystem).partofdomain -eq $false) ',
        '){ exit 0 }',
    ], ' ')
    $installDC = "Install-ADDSForest -Force -DomainName '${domainName}' -Safemodeadministratorpassword ('P@ssw0rd' | ConvertTo-SecureString -AsPlainText -Force)"

    #--------------------------------------------------------------------------------
    # Windows features for Domain Controller installation.
    # AD Cert and ADCS should not exist.
    #--------------------------------------------------------------------------------
    windowsfeature { [
            'AD-Certificate', 
            'RSAT-ADCS',
        ]:
        ensure => absent
    } ->
    windowsfeature { [
            #'ADLDS', 'AD-Federation-Services', 'AD-Domain-Services', 'ADDS-Domain-Controller',
            #'ADRMS', 'ADRMS-Server',
            'RSAT-AD-AdminCenter', 
            'RSAT-ADDS', 
            'RSAT-ADDS-Tools', 
            'RSAT-DNS-Server',
            'RSAT-ADLDS',
            'RSAT-AD-PowerShell',
            'RSAT-RMS',
            'DNS', 'GPMC',
        ]:
        ensure => present
    } ->
    notify { "Test command is $isReadyToBeDC" : } ->
    exec { 'Install AD DS':
        command   => 'Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Restart',
        onlyif    => 'if((Get-WindowsFeature | Where-Object {$_.Name -eq "AD-Domain-Services"}) -eq "False"){ exit 0}',
        logoutput => 'true',
        provider  => powershell,
    } ->
    notify { "Install DC Command is $installDC" : } ->
    exec { 'Install Add Forest':
        command   => $installDC,
        onlyif    => $isReadyToBeDC,
        logoutput => true,
        provider  => powershell,
    }
}
