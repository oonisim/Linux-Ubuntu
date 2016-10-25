#--------------------------------------------------------------------------------
# [Author]  Masayuki Onishi
# [History] Ver 1.0 10JUL2016 initial for Ubuntu 14.04
#--------------------------------------------------------------------------------
# [Function]
# Git
#--------------------------------------------------------------------------------
class site_admin::git {
    file {'/home/wynadmin/repository':
        path => '/home/wynadmin/repository',
        ensure => 'directory',
    }
    vcsrepo { '/home/wynadmin/repository':
        ensure   => present,
        provider => git,
        source   => 'ssh://gitolite3@gitgs.wynyardgroup.com:443/TechSAPAC/Technical/Linux/Ubuntu/Installation/Automation/14.04',
        require  => File['/home/wynadmin/.ssh/gitgs.ssh'],
    }
}
