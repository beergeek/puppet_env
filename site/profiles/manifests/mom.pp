class profiles::mom {

  $manage_r10k          = hiera('profiles::mom::manage_r10k', true)
  $r10k_sources         = hiera_hash('profiles::mom::r10k_sources', undef)
  $manage_hiera         = hiera('profiles::mom::manage_hiera', true)
  $hiera_backends       = hiera_hash('profiles::mom::hiera_backends', undef)
  $hiera_hierarchy      = hiera_array('profiles::mom::hiera_hierarchy', undef)
  $node_groups          = hiera('profiles::mom::node_groups', undef)
  $node_groups_defaults = hiera('profiles::mom::node_groups_defaults')
  $enable_firewall      = hiera('profiles::mom::enable_firewall',true)

  Firewall {
    proto  => tcp,
    action => accept,
    before  => Class['profiles::fw::post'],
    require => Class['profiles::fw::pre'],
  }

  #  Node_group {
  #  require => Package['puppetclassify'],
  #}

  augeas { 'ssl_pub_path':
    context => "/files/${::settings::fileserverconfig}/pe_public",
    changes => [
      "set path ${::settings::ssldir}/public_keys",
      'set allow com0.puppetlabs.vm,com1.puppetlabs.vm'
    ],
    notify => Service['pe-puppetserver'],
  }

  if $enable_firewall {
    firewall { '100 allow puppet access':
      port   => [8140],
    }

    firewall { '100 allow mco access':
      port   => [61613],
    }

    firewall { '100 allow amq access':
      port   => [61616],
    }

    firewall { '100 allow console access':
      port   => [443],
    }

    firewall { '100 allow nc access':
      port   => [4433],
    }

    firewall { '100 allow puppetdb access':
      port   => [8081],
    }
  }

  @@nagios_service { "${::fqdn}_puppet":
    ensure              => present,
    use                 => 'generic-service',
    host_name           => $::fqdn,
    service_description => "Puppet Master",
    check_command       => 'check_http! -p 8140 -S -u /production/node/test',
    target              => "/etc/nagios/conf.d/${::fqdn}_service.cfg",
    notify              => Service['nagios'],
    require             => File["/etc/nagios/conf.d/${::fqdn}_service.cfg"],
  }

  if $manage_r10k and ! $r10k_sources {
    fail('The hash `r10k_sources` must exist when managing r10k')
  }

  if $manage_hiera and (! $hiera_backends or ! $hiera_hierarchy) {
    fail('The hash `hiera_backends` and array `hiera_hierarchy` must exist when managing hiera')
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
      content => template('profiles/hiera.yaml.erb'),
      notify  => Service['pe-puppetserver'],
    }
  }

  Puppet_certificate <<| tag == 'mco_clients' |>>

  package { 'puppetclassify':
    ensure   => present,
    provider => 'puppetserver_gem',
  }

  if $node_groups {
    # new school
    $node_groups. each |String $node_name, Hash $node_hash| {
      node_group { $node_name:
        * => $node_hash,;
        default:
          * => $node_groups_defaults,;
      }
    }
    # old school
    # create_resources('node_group',$node_groups, $node_groups_defaults)
  }

}
