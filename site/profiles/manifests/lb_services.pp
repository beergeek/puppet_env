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
  haproxy::listen { 'http00':
    collect_exported => true,
    ipaddress        => $::ipaddress_eth1,
    ports            => '80',
    options          => {
      'mode'         => 'tcp',
    },
  }
  haproxy::listen { 'https00':
    collect_exported => true,
    ipaddress        => $::ipaddress_eth1,
    ports            => '443',
    options          => {
      'mode'         => 'tcp',
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
  haproxy::listen { 'mco00':
    collect_exported => true,
    ipaddress        => $::ipaddress_eth1,
    ports            => '61613',
    options          => {
      'mode'         => 'tcp',
      'balance'      => 'source',
    },
  }

  firewall { '105 allow puppet access':
    port   => [8140],
    proto  => tcp,
    action => accept,
  }

  firewall { '107 allow mco access':
    port   => [61613],
    proto  => tcp,
    action => accept,
  }

  firewall { '106 allow stats access':
    port   => [9090],
    proto  => tcp,
    action => accept,
  }
}
