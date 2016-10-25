#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial for Ubuntu 14.04
#--------------------------------------------------------------------------------
# [Function]
# Puppet Apache configuration
#--------------------------------------------------------------------------------
class site_apache::server {
	$apacheuser = $::osfamily ? {
		'Debian' => 'www-data',
		default  => 'apache',
	}

    class {'apache': 
        default_vhost => false,
    }
    apache::vhost {'apache_default':
        port          => 80,
#        ssl           => false,
        docroot       => '/var/www/html',
        scriptalias   => '/var/www/cgi-bin',
        docroot_owner => $apacheuser,
        docroot_group => $apacheuser,
        docroot_mode  => '0644',
    }
} 