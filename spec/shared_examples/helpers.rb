require 'spec_helper'

shared_examples_for 'test_linux' do |fact_set|
  describe "Security Checks" do
    it { is_expected.to satisfy_file_resource_requirements }
  end

  describe "SOE Checks" do
    it do
      is_expected.to contain_class('firewall').with({
        'ensure' => 'running',
      })
    end

    it do
      is_expected.to contain_class('profile::fw::pre')
    end

    it do
      is_expected.to contain_class('profile::fw::post')
    end

    it do
      is_expected.to contain_class('profile::ssh')
    end

    it do
      is_expected.to contain_class('profile::sudo')
    end

    it do
      is_expected.to contain_class('profile::monitoring')
    end

    it do
      is_expected.to contain_class('profile::repos')
    end

    it do
      is_expected.to contain_class('profile::dns')
    end

    it do
      is_expected.to contain_class('profile::time_locale')
    end

    it do
      is_expected.to contain_sysctl('kernel.msgmnb').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '65536',
      })
    end

    it do
      is_expected.to contain_sysctl('kernel.msgmax').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '65536',
      })
    end

    it do
      is_expected.to contain_sysctl('kernel.shmmax').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '2588483584',
      })
    end

    it do
      is_expected.to contain_sysctl('kernel.shmall').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '2097152',
      })
    end

    it do
      is_expected.to contain_sysctl('fs.file-max').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '6815744',
      })
    end

    it do
      is_expected.to contain_sysctl('net.ipv4.tcp_keepalive_time').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '1800',
      })
    end

    it do
      is_expected.to contain_sysctl('net.ipv4.tcp_keepalive_intvl').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '30',
      })
    end

    it do
      is_expected.to contain_sysctl('net.ipv4.tcp_keepalive_probes').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '5',
      })
    end

    it do
      is_expected.to contain_sysctl('net.ipv4.tcp_fin_timeout').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '30',
      })
    end

    it do
      is_expected.to contain_sysctl('kernel.shmmni').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '4096',
      })
    end

    it do
      is_expected.to contain_sysctl('fs.aio-max-nr').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '1048576',
      })
    end

    it do
      is_expected.to contain_sysctl('kernel.sem').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '250 32000 100 128',
      })
    end

    it do
      is_expected.to contain_sysctl('net.ipv4.ip_local_port_range').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '9000 65500',
      })
    end

    it do
      is_expected.to contain_sysctl('net.core.rmem_default').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '262144',
      })
    end

    it do
      is_expected.to contain_sysctl('net.core.rmem_max').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '4194304',
      })
    end

    it do
      is_expected.to contain_sysctl('net.core.wmem_default').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '262144',
      })
    end

    it do
      is_expected.to contain_sysctl('net.core.wmem_max').with({
        'ensure'    => 'present',
        'permanent' => 'yes',
        'value'     => '1048576',
      })
    end

    it do
      is_expected.to contain_firewall('100 allow ssh access').with({
        'dport'  => '22',
        'proto'  => 'tcp',
        'action' => 'accept',
      })
    end

    it do
      is_expected.to contain_file('/etc/issue').with({
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' => 'This system is the property of Puppet. Unauthorised access is not permitted',
      })
    end

    it do
      is_expected.to contain_file('/etc/issue.net').with({
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' => 'This system is the property of Puppet. Unauthorised access is not permitted',
      })
    end

    it do
      is_expected.to contain_class('ssh::server').with({
        'storeconfigs_enabled' => false,
        'options'              => {
          'Port'                            => '22',
          'AcceptEnv'                       => 'LANG LC_*',
          'ChallengeResponseAuthentication' => false,
          'PermitRootLogin'                 => true,
          'PrintMotd'                       => false,
          'Subsystem'                       => 'sftp /usr/libexec/openssh/sftp-server',
          'UsePAM'                          => true,
          'X11Forwarding'                   => true,
          'RSAAuthentication'               => true,
          'PubkeyAuthentication'            => true,
          'AllowGroups'                     => 'root vagrant centos ubuntu',
        }
      })
    end

    it do
      is_expected.to contain_class('sudo').with({
        'purge'               => true,
        'config_file_replace' => true,
      })
    end

    it do
      is_expected.to contain_sudo__conf('centos').with({
        'priority'  => '10',
        'content'   => '%centos ALL=(ALL) NOPASSWD: ALL',
      })
    end

    it do
      is_expected.to contain_sudo__conf('ubuntu').with({
        'priority'  => '10',
        'content'   => '%ubuntu ALL=(ALL) NOPASSWD: ALL',
      })
    end

    it do
      is_expected.to contain_sudo__conf('vagrant').with({
        'priority'  => '10',
        'content'   => '%vagrant ALL=(ALL) NOPASSWD: ALL',
      })
    end

    it do
      is_expected.to contain_class('epel')
    end

    it do
      is_expected.to contain_package('nagios-common').with({
        'ensure' => 'present',
      })
    end

    it do
      is_expected.to contain_package('nrpe').with({
        'ensure' => 'present',
      })
    end

    it do
      is_expected.to contain_service('nrpe').with({
        'ensure' => 'running',
        'enable' => true,
      })
    end

    it do
      is_expected.to contain_firewall('101 accept NRPE').with({
        'dport'  => '5666',
        'proto'  => 'tcp',
        'action' => 'accept',
      })
    end

    it do
      is_expected.to contain_file('/etc/sysconfig/i18n').with({
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
    end

    it do
      is_expected.to contain_file_line('locale').with({
        'ensure' => 'present',
        'path'   => '/etc/sysconfig/i18n',
        'line'   => 'LANG=en_AU.utf8',
        'match'  => 'LANG=',
      })
    end

    it do
      is_expected.to contain_class('timezone').with({
        'timezone' => 'UTC',
      })
    end

    it do
      is_expected.to contain_class('ntp').with({
        'servers' => ['0.au.pool.ntp.org','1.au.pool.ntp.org','2.au.pool.ntp.org','3.au.pool.ntp.org'],
      })
    end

    it do
      is_expected.to contain_class('resolv_conf').with({
        'domainname'  => 'puppet.vm',
        'nameservers' => ['10.0.2.3'],
      })
    end

    it do
      is_expected.to contain_host('localhost').with({
        'ensure'        => 'present',
        'host_aliases'  => ['localhost.localdomai','localhost6','localhost6.localdomain6'],
        'ip'            => '127.0.0.1',
      })
    end

    it do
      is_expected.to contain_firewall('000 accept all icmp').with({
        'proto'   => 'icmp',
        'action'  => 'accept',
      })
    end

    it do
      is_expected.to contain_firewall('001 accept all to lo interface').with({
        'proto'   => 'all',
        'action'  => 'accept',
        'iniface' => 'lo'
      })
    end

    it do
      is_expected.to contain_firewall('002 accept related established rules').with({
        'proto'   => 'all',
        'state'   => ['RELATED', 'ESTABLISHED'],
        'action'  => 'accept',
      })
    end

    it do
      is_expected.to contain_firewall('999 drop all').with({
        'proto'   => 'all',
        'action'  => 'drop',
      })
    end
  end
end
