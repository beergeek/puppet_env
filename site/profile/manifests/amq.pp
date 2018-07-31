class profile::amq (
  Boolean $enable_firewall = true
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
    fail('Buggered if I know your IP Address')
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

  @@haproxy::balancermember { "mco00-${facts['fqdn']}":
    listening_service => 'mco00',
    server_names      => $facts['fqdn'],
    ipaddresses       => $ip,
    ports             => '61613',
    options           => 'check',
  }
}
