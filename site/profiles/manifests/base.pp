class profiles::base {

  $sysctl_settings  = hiera('profiles::base::sysctl_settings')
  $sysctl_defaults  = hiera('profiles::base::sysctl_defaults')
  $mco_client_array = hiera_array('profiles::base::mco_client_array', undef)

  class { 'firewall': }
  class {['profiles::fw::pre','profiles::fw::post']:}

  Firewall {
    before  => Class['profiles::fw::post'],
    require => Class['profiles::fw::pre'],
  }

  create_resources(sysctl,$sysctl_settings, $sysctl_defaults)
  ensure_packages(['ruby'])

  @@host { $::fqdn:
    ensure        => present,
    host_aliases  => [$::hostname],
    ip            => $::ipaddress_eth1,
  }

  host { 'localhost':
    ensure       => present,
    host_aliases => ['localhost.localdomai','localhost6','localhost6.localdomain6'],
    ip           => '127.0.0.1',
  }

  Host <<| |>>

  resources { 'host':
    purge => true,
  }

  if $mco_client_array {
    $mco_client_array.each |$cert_title| {
      file { $cert_title:
        ensure  => file,
        path    => "/etc/puppetlabs/mcollective/ssl/clients/${cert_title}",
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
        content => file("${::settings::ssldir}/public_keys/${cert_title}.pem",'/dev/null'),
        notify  => Service['mcollective'],
      }
    }
  }

  # setup NTP client
  include profiles::ntp_client

  # setup SSH server and firewall
  class { 'ssh::server':
      storeconfigs_enabled => false,
      options              => {
        'PermitRootLogin'  => 'yes',
        'Port'             => [22],
      },
  }
  firewall { '104 allow http ssh access':
    port   => [22],
    proto  => tcp,
    action => accept,
  }
}
