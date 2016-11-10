#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial for Ubuntu 14.04
#--------------------------------------------------------------------------------
# [Function]
# Puppet DNS configuration for Ubuntu (not tested with CentOS) for Thias bind
# 
# [Dependencies]
# Thias bind (https://forge.puppet.com/thias/bind) Version 0.5.2 Feb 2nd 2016
# The module template named.conf.erb has been modified to work with Ubuntu 14.04. 
#--------------------------------------------------------------------------------
class site_dns::server {
    include bind
    bind::server::conf { '/etc/bind/named.conf':
        listen_on_addr    => [ 'any' ],
        listen_on_v6_addr => [ 'any' ],
        allow_query       => [ 'any' ],
        directory         => '/etc/bind',
        includes          => ['/etc/bind/named.conf.local', '/etc/bind/named.conf.default-zones'],
        forwarders        => [ '143.96.102.2', '143.96.102.3', '8.8.8.8', '8.8.4.4' ],
        zones             => {
            'wynyarddemo.local' => [
                'type master',
                'file "db.wynyarddemo.local"',
            ],
            '102.96.143.in-addr.arpa' => [
                'type master',
                'file "102.96.143.in-addr.arpa"',
            ],
        },
    }
    bind::server::file { [
            'db.wynyarddemo.local',
            '102.96.143.in-addr.arpa',
        ]:
        zonedir     => '/etc/bind',
        source_base => 'puppet:///site_files/site_dns/files/',
    }
}