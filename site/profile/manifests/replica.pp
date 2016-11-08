class profile::replica () inherits profile::com {

  $enable_firewall = hiera('profile::replica::enable_firewall',true)

  if $enable_firewall {
    Firewall {
      proto   => tcp,
      action  => accept,
      before  => Class['profile::fw::post'],
      require => Class['profile::fw::pre'],
    }

    firewall { '100 allow code manager access':
      dport   => [8170],
    }

    firewall { '100 allow puppetdb access':
      dport  => [8081],
    }

    firewall { '100 allow classifier access':
      dport  => [4433],
    }

    firewall { '100 allow postgresql access':
      dport  => [5432],
    }
  }

}
