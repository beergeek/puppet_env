class profile::amq {

  $enable_firewall = hiera('profile::com::enable_firewall',true)
  if has_key($::networking['interfaces'],'enp0s8') {
    $ip = $::networking['interfaces']['enp0s8']['ip']
  } elsif has_key($::networking['interfaces'],'eth1') {
    $ip = $::networking['interfaces']['eth1']['ip']
  } elsif has_key($::networking['interfaces'],'enp0s3') {
    $ip = $::networking['interfaces']['enp0s3']['ip']
  } elsif has_key($::networking['interfaces'],'eth0') {
    $ip = $::networking['interfaces']['eth0']['ip']
  } else {
    fail("Buggered if I know your IP Address")
  }

  if $enable_firewall {
    Firewall {
      before  => Class['profile::fw::post'],
      require => Class['profile::fw::pre'],
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

  @@haproxy::balancermember { "mco00-${::fqdn}":
    listening_service => 'mco00',
    server_names      => $::fqdn,
    ipaddresses       => $ip,
    ports             => '61613',
    options           => 'check',
  }
}
