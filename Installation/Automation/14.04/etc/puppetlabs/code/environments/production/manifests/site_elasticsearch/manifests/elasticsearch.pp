$site_elasticsearch_clustername='ACA2_Monitor'
$site_elasticsearch_packageurl='https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.3.3/elasticsearch-2.3.3.rpm'

class site_elasticsearch::elasticsearch{
    class { 'elasticsearch':
        ensure => 'present',
        autoupgrade => false,
        java_install => true,
        package_url => $site_elasticsearch_packageurl,
        #version => '1.7.3',
        status => 'enabled',
        datadir => '/data/elasticsearch',
        config => {
            'cluster.name' => $site_elasticsearch_clustername,
            'node.name'    => $::hostname,
            'network.host' => $::hostname,
            'bootstrap.mlockall' => true,
            'discovery.zen.ping.multicast.enabled' => false
        }
    }
    #--------------------------------------------------------------------------------
    # Instance definition
    #--------------------------------------------------------------------------------
    elasticsearch::instance { $::hostname: }
    #--------------------------------------------------------------------------------
    # Plugin installations
    #--------------------------------------------------------------------------------
    elasticsearch::plugin{'mobz/elasticsearch-head':
      instances  => $::hostname
    }
    elasticsearch::plugin{'lmenezes/elasticsearch-kopf':
      instances  => $::hostname
    }
}
