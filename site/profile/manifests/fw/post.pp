class profile::fw::post {

  Firewall {
    before => undef,
  }

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }

}
