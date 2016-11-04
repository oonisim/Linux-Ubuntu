define site_user::ssh_user ($password, $key, $keytype){
    @user { "${name}":
        comment  => "Operation user",
        ensure   => present,
        password => "${password}", 
        home     => "/home/${name}",
        shell    => '/bin/bash',
    }
    realize(User["${name}"])
 
    @file { "/home/${name}":
        ensure => directory,
        mode => '0700',
        owner => "${name}",
        require => User["${name}"],
    }
    realize(File["/home/${name}"])
 
    @file { "/home/${name}/.ssh":
        ensure => directory,
        mode => '0700',
        owner => "${name}",
        require => File["/home/${name}"],
    }
    realize(File["/home/${name}/.ssh"])
 
    @ssh_authorized_key { "${name}_key":
        key => "${key}",
        type => "${keytype}",
        user => "${name}",
        require => File["/home/${name}/.ssh"],
    }
    realize(Ssh_authorized_key["${name}_key"])
}
