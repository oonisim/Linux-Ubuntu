$cassandra_version = '2.1.13'
$cassandra_pkgname = 'cassandra21'
class site_cassandra::cassandra{
    #--------------------------------------------------------------------------------
    # Install Cassandra on the node.
    #--------------------------------------------------------------------------------
    file { '/data/cassandra':
        #--------------------------------------------------------------------------------
        # Need to create in advance, otherwise data_file_directories/commitlog_directory fail.
        #--------------------------------------------------------------------------------
        path   => '/data/cassandra',
        ensure => directory,
    } ->
    class { cassandra::java:
        #--------------------------------------------------------------------------------
        # Pre-requisite Java package.
        #--------------------------------------------------------------------------------
    } ->
    class { cassandra::datastax_repo: 
        #--------------------------------------------------------------------------------
        # Pre-requisite Java package.
        #--------------------------------------------------------------------------------
        pkg_url               => "http://rpm.datastax.com/community",
    } ->
    class { 'cassandra':
        #--------------------------------------------------------------------------------
        # Cassandra Package
        #--------------------------------------------------------------------------------
        package_name          => $cassandra_pkgname, 
        package_ensure        => $cassandra_version,
        require               => Class['cassandra::datastax_repo', 'cassandra::java'],
        #  authenticator      => 'PasswordAuthenticator',
        cluster_name          => 'MasaTestCassandraCluster',
        endpoint_snitch       => 'GossipingPropertyFileSnitch',
        listen_address        => $::ipaddress,
        rpc_address           => $::ipaddress,
        seeds                 => $::ipaddress,
        service_systemd       => true,
        commitlog_directory   => '/data/cassandra/commitlog',    # Not a list
        data_file_directories => ['/data/cassandra/data'],       # Must be list
    }
    #--------------------------------------------------------------------------------
    # Install OpsCenter
    #--------------------------------------------------------------------------------
    class { 'cassandra::datastax_agent':
        package_ensure        => 'present',
        stomp_interface       => $::ipaddress,
    } ->
    class { '::cassandra::opscenter':
        require               => Class['cassandra'],
    }

    #--------------------------------------------------------------------------------
    # Create schemas
    #--------------------------------------------------------------------------------
    class { 'cassandra::schema':
        cqlsh_password => 'cassandra',
        cqlsh_user     => 'cassandra',
        indexes        => {
            'users_lname_idx' => {
                table    => 'users',
                keys     => 'lname',
                keyspace => 'mykeyspace',
            },
        },
        keyspaces      => {
            'mykeyspace' => {
                durable_writes  => false,
                replication_map => {
                    keyspace_class     => 'SimpleStrategy',
                    replication_factor => 1,
                },
            }
        },
        tables        => {
            'users' => {
                columns  => {
                    user_id       => 'int',
                    fname         => 'text',
                    lname         => 'text',
                    'PRIMARY KEY' => '(user_id)',
                },
                keyspace => 'mykeyspace',
            },
        },
    }
}

