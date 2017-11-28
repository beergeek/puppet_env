class profile::com (
  Hash[Hash] $firewall_hash,
  Hash $firewall_defaults,
  Boolean $enable_firewall = true,
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
    $firewall_hash.each |String $firewall_rule, Hash $firewall_data|{
      firewall { $firewall_rule:
        * => $firewall_data,;
        default:
          * => $firewall_defaults;
      }
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
}
