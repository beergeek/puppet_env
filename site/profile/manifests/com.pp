class profile::com (
  $enable_firewall = true
) {

  if has_key($facts['networking']['interfaces'],'enp0s8') {
    $ip = $facts['networking']['interfaces']['enp0s8']['ip']
  } elsif has_key($facts['networking']['interfaces'],'eth1') {
    $ip = $facts['networking']['interfaces']['eth1']['ip']
  } elsif has_key($facts['networking']['interfaces'],'enp0s3') {
    $ip = $facts['networking']['interfaces']['enp0s3']['ip']
  } elsif has_key($facts['networking']['interfaces'],'eth0') {
    $ip = $facts['networking']['interfaces']['eth0']['ip']
  } else {
    fail("Buggered if I know your IP Address")
  }

  if $enable_firewall {
    Firewall {
      before  => Class['profile::fw::post'],
      require => Class['profile::fw::pre'],
    }

    firewall { '100 allow puppet access':
      dport  => [8140],
      proto  => tcp,
      action => accept,
    }

    firewall { '100 allow mco access':
      dport  => [61613],
      proto  => tcp,
      action => accept,
    }

    firewall { '100 allow amq access':
      dport  => [61616],
      proto  => tcp,
      action => accept,
    }
  }

  if $trusted['extensions']['pp_role'] != 'replica' {
    @@haproxy::balancermember { "master00-${facts['fqdn']}":
      listening_service => 'puppet00',
      server_names      => $facts['fqdn'],
      ipaddresses       => $ip,
      ports             => '8140',
      options           => 'check',
    }
    @@haproxy::balancermember { "mco00-${facts['fqdn']}":
      listening_service => 'mco00',
      server_names      => $facts['fqdn'],
      ipaddresses       => $ip,
      ports             => '61613',
      options           => 'check',
    }
  }

  @@puppet_certificate { "${facts['fqdn']}-peadmin":
    ensure => present,
    tag    => 'mco_clients',
  }

  puppet_enterprise::mcollective::client { "${facts['fqdn']}-peadmin":
    activemq_brokers => [$::clientcert],
    logfile          => "/var/lib/${::fqdn}-peadmin/${facts['fqdn']}-peadmin.log",
    create_user      => true,
  }

}
