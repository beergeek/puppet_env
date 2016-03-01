class profile::com {

  $manage_r10k    = hiera('profile::com::manage_r10k', true)
  $r10k_sources   = hiera_hash('profile::com::r10k_sources', undef)
  $manage_hiera   = hiera('profile::com::manage_hiera', true)
  $hiera_backends = hiera_hash('profile::com::hiera_backends', undef)
  $hiera_hierarchy = hiera_array('profile::com::hiera_hierarchy', undef)

  Firewall {
    before  => Class['profile::fw::post'],
    require => Class['profile::fw::pre'],
  }

  Pe_ini_setting {
    path    => $::settings::config,
    section => 'main',
    notify  => Service['pe-puppetserver'],
  }

  file { '/etc/puppetlabs/puppet/ssl/public_keys':
    ensure  => directory,
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    recurse => true,
    purge   => false,
    source  => 'puppet:///pe_public',
  }

  firewall { '100 allow puppet access':
    port   => [8140],
    proto  => tcp,
    action => accept,
  }

  firewall { '100 allow mco access':
    port   => [61613],
    proto  => tcp,
    action => accept,
  }

  firewall { '100 allow amq access':
    port   => [61616],
    proto  => tcp,
    action => accept,
  }

  pe_ini_setting { 'pe_user':
    ensure  => present,
    setting => 'user',
    value   => 'pe-puppet',
  }

  pe_ini_setting { 'pe_group':
    ensure  => present,
    setting => 'group',
    value   => 'pe-puppet',
  }

  if $manage_r10k and ! $r10k_sources {
    fail('The hash `r10k_sources` must exist when managing r10k')
  }

  if $manage_hiera and (! $hiera_backends or ! $hiera_hierarchy) {
    fail('The hash `hiera_backends` and array `hiera_hierarchy` must exist when managing hiera')
  }

  @@haproxy::balancermember { "master00-${::fqdn}":
    listening_service => 'puppet00',
    server_names      => $::fqdn,
    ipaddresses       => $::ipaddress_eth1,
    ports             => '8140',
    options           => 'check',
  }
  @@haproxy::balancermember { "mco00-${::fqdn}":
    listening_service => 'mco00',
    server_names      => $::fqdn,
    ipaddresses       => $::ipaddress_eth1,
    ports             => '61613',
    options           => 'check',
  }

  if $manage_r10k {
    class { '::r10k':
      version                 => '2.0.3',
      configfile              => '/etc/puppetlabs/r10k/r10k.yaml',
      sources                 => $r10k_sources,
      notify                  => Exec['r10k_sync'],
    }

    exec { 'r10k_sync':
      command     => '/opt/puppetlabs/puppet/bin/r10k deploy environment -p',
      refreshonly => true,
    }

    include ::r10k::mcollective
  }

  if $manage_hiera {
    package { 'hiera-eyaml':
      ensure   => present,
      provider => 'puppetserver_gem',
      before   => File['/etc/puppetlabs/code/hiera.yaml'],
    }

    file { '/etc/puppetlabs/puppet/ssl/private_key.pkcs7.pem':
      ensure  => file,
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0600',
      content => file('/etc/puppetlabs/puppet/ssl/private_key.pkcs7.pem'),
      before   => File['/etc/puppetlabs/code/hiera.yaml'],
    }

    file { '/etc/puppetlabs/puppet/ssl/public_key.pkcs7.pem':
      ensure  => file,
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0644',
      content => file('/etc/puppetlabs/puppet/ssl/public_key.pkcs7.pem'),
      before   => File['/etc/puppetlabs/code/hiera.yaml'],
    }

    file { '/etc/puppetlabs/code/hiera.yaml':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('profile/hiera.yaml.erb'),
      notify  => Service['pe-puppetserver'],
    }
  }

  @@puppet_certificate { "${::fqdn}-peadmin":
    ensure => present,
    tag    => 'mco_clients',
  }

  puppet_enterprise::mcollective::client { "${::fqdn}-peadmin":
    activemq_brokers => [$::clientcert],
    logfile          => "/var/lib/${::fqdn}-peadmin/${::fqdn}-peadmin.log",
    create_user      => true,
  }

}
