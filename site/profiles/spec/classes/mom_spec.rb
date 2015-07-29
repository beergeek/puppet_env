require 'spec_helper'
describe 'profiles::mom' do
  let(:pre_condition) {
    [
      'class { "puppet_enterprise":
        certificate_authority_host    => "master.puppetlabs.vm",
        database_host                 => "master.puppetlabs.vm",
        puppetdb_host                 => "master.puppetlabs.vm",
        puppet_master_host            => "master.puppetlabs.vm",
        puppetdb_database_name        => "pe-puppetdb",
        puppetdb_database_user        => "pe-puppetdb",
        console_host                  => "master.puppetlabs.vm",
        database_port                 => 5432,
        database_ssl                  => true,
        console_port                  => 443,
        puppetdb_port                 => 8081,
        mcollective_middleware_hosts  => ["master.puppetlabs.vm"],
      }',
      'class { "puppet_enterprise::profile::master": }',
      'class { "profiles::fw::pre": }',
      'class { "profiles::fw::post": }'
    ]
  }
  let(:facts) {
    {
      :kernel                     => 'Linux',
      :osfamily                   => 'RedHat',
      :operatingsystem            => 'RedHat',
      :operatingsystemmajrelease  => '6',
      :concat_basedir             => '/tmp',
      :pe_concat_basedir          => '/tmp',
    }
  }

  context 'default' do
    it { should compile.with_all_deps }

    it {
      should contain_firewall('100 allow puppet access').with(
        'port'    => '8140',
        'proto'   => 'tcp',
        'action'  => 'accept',
      ).that_comes_before('class[profiles::fw::post]')
      .that_requires('class[profiles::fw::pre]')
    }

    it {
      should contain_firewall('100 allow mco access').with(
        'port'    => '61613',
        'proto'   => 'tcp',
        'action'  => 'accept',
      ).that_comes_before('class[profiles::fw::post]')
      .that_requires('class[profiles::fw::pre]')
    }

    it {
      should contain_firewall('100 allow amq access').with(
        'port'    => '61616',
        'proto'   => 'tcp',
        'action'  => 'accept',
      ).that_comes_before('class[profiles::fw::post]')
      .that_requires('class[profiles::fw::pre]')
    }

    it {
      should contain_firewall('100 allow console access').with(
        'port'    => '443',
        'proto'   => 'tcp',
        'action'  => 'accept',
      ).that_comes_before('class[profiles::fw::post]')
      .that_requires('class[profiles::fw::pre]')
    }

    it {
      should contain_firewall('100 allow nc access').with(
        'port'    => '4433',
        'proto'   => 'tcp',
        'action'  => 'accept',
      ).that_comes_before('class[profiles::fw::post]')
      .that_requires('class[profiles::fw::pre]')
    }

    it {
      should contain_firewall('100 allow reports access').with(
        'port'    => '4435',
        'proto'   => 'tcp',
        'action'  => 'accept',
      ).that_comes_before('class[profiles::fw::post]')
      .that_requires('class[profiles::fw::pre]')
    }

    it {
      should contain_firewall('100 allow puppetdb access').with(
        'port'    => '8081',
        'proto'   => 'tcp',
        'action'  => 'accept',
      ).that_comes_before('class[profiles::fw::post]')
      .that_requires('class[profiles::fw::pre]')
    }

    it {
      should contain_class('r10k').with(
        'configfile'  => '/etc/puppetlabs/r10k/r10k.yaml',
        'sources'     => {'base' => {'remote' => 'https://github.com/beergeek/puppet_env.git','basedir' => '/etc/puppetlabs/puppet/environments'}},
      ).that_notifies('Exec[r10k_sync]')
    }

    it {
      should contain_exec('r10k_sync').with(
        'command'     => '/opt/puppet/bin/r10k deploy environment -p',
        'refreshonly' => true,
      )
    }

    it {
      should contain_class('r10k::mcollective')
    }

    it {
      should contain_file('/etc/puppetlabs/puppet/hiera.yaml').with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      ).with_content(/^\s*:datadir: "\/etc\/puppetlabs\/puppet\/environments\/%{environment}\/hieradata"/)
      .that_notifies('Service[pe-puppetserver]')
    }

  end
end
