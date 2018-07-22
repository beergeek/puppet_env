class profile::replica (
  Boolean $enable_firewall = true,
) inherits profile::com {

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

    firewall { '100 allow console access':
      dport   => [443],
    }
  }

}
