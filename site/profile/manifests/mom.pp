class profile::mom {

  require profile::base

  $manage_hiera         = hiera('profile::mom::manage_hiera', true)
  $hiera_backends       = hiera_hash('profile::mom::hiera_backends', undef)
  $hiera_hierarchy      = hiera_array('profile::mom::hiera_hierarchy', undef)
  $node_groups          = hiera('profile::mom::node_groups', undef)
  $node_groups_defaults = hiera('profile::mom::node_groups_defaults')
  $enable_firewall      = hiera('profile::mom::enable_firewall',true)
  $manage_eyaml         = hiera('profile::mom::manage_eyaml', false)

  Firewall {
    proto  => tcp,
    action => accept,
    before  => Class['profile::fw::post'],
    require => Class['profile::fw::pre'],
  }

  #  Node_group {
  #  require => Package['puppetclassify'],
  #}

  class { 'app_update':
    application => true,
    agent       => false,
  }

  augeas { 'ssl_pub_path':
    context => "/files/${::settings::fileserverconfig}/pe_public",
    changes => [
      "set path ${::settings::ssldir}/public_keys",
      'set allow com0.puppetlabs.vm,com1.puppetlabs.vm'
    ],
    notify => Service['pe-puppetserver'],
  }

  augeas { 'iis_file_path':
    context => "/files/${::settings::fileserverconfig}/iis_files",
    changes => [
      "set path /opt/iis_files",
      'set allow *'
    ],
    notify => Service['pe-puppetserver'],
  }

  if $enable_firewall {
    firewall { '100 allow puppet access':
      port   => [8140],
    }

    firewall { '100 allow pcp access':
      port   => [8142],
    }

    firewall { '100 allow pcp client access':
      port   => [8143],
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

  if $manage_hiera and (! $hiera_backends or ! $hiera_hierarchy) {
    fail('The hash `hiera_backends` and array `hiera_hierarchy` must exist when managing hiera')
  }

  if $manage_hiera {
    package { 'hiera-eyaml':
      ensure   => present,
      provider => 'puppetserver_gem',
      before   => File['/etc/puppetlabs/code/hiera.yaml'],
    }

    if $manage_eyaml {
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

  Puppet_certificate <<| tag == 'mco_clients' |>>

  package { 'puppetclassify':
    ensure   => present,
    provider => 'puppetserver_gem',
  }

  if $node_groups {
    # new school
    $node_groups.each |String $node_name, Hash $node_hash| {
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
