require 'spec_helper'
describe 'cassandra' do
  let(:pre_condition) do
    [
      'class apt () {}',
      'class apt::update () {}',
      'define apt::key ($id, $source) {}',
      'define apt::source ($location, $comment, $release, $include) {}',
      'define ini_setting($ensure = nil,
         $path,
         $section,
         $key_val_separator       = nil,
         $setting,
         $value                   = nil) {}'
    ]
  end

  let!(:stdlib_stubs) do
    MockFunction.new('concat') do |f|
      f.stubbed.with([], '/etc/cassandra')
       .returns(['/etc/cassandra'])
      f.stubbed.with([], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra/default.conf'])
      f.stubbed.with(['/etc/cassandra'], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra', '/etc/cassandra/default.conf'])
      f.stubbed.with(['/etc/cassandra'], '/etc/dse/cassandra')
       .returns(['/etc/cassandra', '/etc/dse/cassandra'])
    end
    MockFunction.new('strftime') do |f|
      f.stubbed.with('/var/lib/cassandra-%F')
       .returns('/var/lib/cassandra-YYYY-MM-DD')
    end
  end

  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it { should contain_class('cassandra') }
    it { should contain_file('/etc/cassandra/default.conf') }
    it { should contain_file('/etc/cassandra/default.conf/cassandra.yaml') }
    it do
      should contain_service('cassandra').with(
        'ensure' => 'running',
        'enable' => 'true'
      )
    end
    it { should contain_package('cassandra').with(name: 'cassandra22') }
    it { is_expected.not_to contain_yumrepo('datastax') }
    it do
      should contain_file('/var/lib/cassandra/data').with(
        'ensure' => 'directory',
        'owner'  => 'cassandra',
        'group'  => 'cassandra',
        'mode'   => '0750'
      )
    end
    it do
      should contain_file('/var/lib/cassandra/commitlog').with(
        'ensure' => 'directory',
        'owner'  => 'cassandra',
        'group'  => 'cassandra',
        'mode'   => '0750'
      )
    end
    it do
      should contain_file('/var/lib/cassandra/saved_caches').with(
        'ensure' => 'directory',
        'owner'  => 'cassandra',
        'group'  => 'cassandra',
        'mode'   => '0750'
      )
    end
    it do
      is_expected
        .not_to contain_file('/usr/lib/systemd/system/cassandra.service')
    end
  end

  context 'On a RedHat OS with manage_dsc_repo set to true' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        manage_dsc_repo: true
      }
    end

    it { should contain_yumrepo('datastax') }
  end

  context 'Install DSE on a Red Hat family OS.' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        package_ensure: '4.7.0-1',
        package_name: 'dse-full',
        cluster_name: 'DSE Cluster',
        config_path: '/etc/dse/cassandra',
        service_name: 'dse',
        service_systemd: true
      }
    end

    it do
      should contain_file('/etc/dse/cassandra/cassandra.yaml')
      should contain_file('/etc/dse/cassandra')
      should contain_file('/usr/lib/systemd/system/dse.service')
      should contain_file('/etc/dse/cassandra/cassandra-rackdc.properties')
      should contain_package('cassandra').with(
        ensure: '4.7.0-1',
        name: 'dse-full'
      )
      is_expected.to contain_service('cassandra').with_name('dse')
    end
  end

  context 'CASSANDRA-9822 activated on Red Hat' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        cassandra_9822: true
      }
    end

    it { is_expected.not_to contain_file('/etc/init.d/cassandra') }
  end

  context 'Systemd file can be activated on Red Hat' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    let :params do
      {
        service_systemd: true
      }
    end

    it { should contain_file('/usr/lib/systemd/system/cassandra.service') }

    it do
      is_expected.to contain_exec('cassandra_reload_systemctl').with(
        command: '/usr/bin/systemctl daemon-reload',
        refreshonly: true
      )
    end
  end
end
