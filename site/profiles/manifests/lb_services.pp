class profiles::lb_services {

  Firewall {
    before  => Class['profiles::fw::post'],
    require => Class['profiles::fw::pre'],
  }

  @@host { 'puppet.puppetlabs.vm':
    ensure       => present,
    host_aliases => ['puppet'],
    ip           => $::ipaddress_eth1,
  }

  include haproxy
  haproxy::listen { 'stats':
    ipaddress => $::ipaddress_eth1,
    ports     => '9090',
    options   => {
      'mode'  => 'http',
      'stats' => ['uri /', 'auth puppet:puppet']
      },
  }
  haproxy::listen { 'puppet00':
    collect_exported => true,
    ipaddress        => $::ipaddress_eth1,
    ports            => '8140',
    options          => {
      'mode'         => 'tcp',
    },
  }

  firewall { '105 allow puppet access':
    port   => [8140],
    proto  => tcp,
    action => accept,
  }
}
