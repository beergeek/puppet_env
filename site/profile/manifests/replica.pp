class profile::replica () inherits profile::com {

  $enable_firewall = hiera('profile::replica::enable_firewall',true)

  if $enable_firewall {
    Firewall {
      proto   => tcp,
      action  => accept,
      before  => Class['profile::fw::post'],
      require => Class['profile::fw::pre'],
    }

    firewall { '100 allow postgresql access':
      dport  => [5432],
    }
  }

}
