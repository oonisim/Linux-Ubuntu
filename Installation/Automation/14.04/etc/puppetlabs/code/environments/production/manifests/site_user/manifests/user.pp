define site_user::user ($password, $key, $keytype){
    @site_user::ssh_user{$name:
        password => "${password}",
        key      => "${key}",
        keytype  => "${keytype}",
    }
    realize(Site_user::Ssh_user["${name}"])
}
