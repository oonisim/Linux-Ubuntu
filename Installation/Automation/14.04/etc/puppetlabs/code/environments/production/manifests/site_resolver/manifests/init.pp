#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial
#--------------------------------------------------------------------------------
# [Function]
# /etc/resolv.conf configuration.
# 
# [Dependencies]
# Mount point configuration.
#--------------------------------------------------------------------------------
class site_resolver {
    file { '/etc/resolv.conf':
        ensure => present,
        source => 'puppet:///site_files/site_resolver/files/resolv.conf',
    }
}

