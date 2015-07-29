require 'spec_helper'
describe 'roles::mom' do
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
    ]
  }
  let(:facts) {
    {
      :kernel                     => 'Linux',
      :osfamily                   => 'RedHat',
      :operatingsystem            => 'RedHat',
      :operatingsystemmajrelease  => '6',
      :concat_basedir             => '/tmp',
      :pe_concat_basedir          => '/tmp/cc',
    }
  }

  context 'default' do
    it { should compile.with_all_deps }
  end
end
