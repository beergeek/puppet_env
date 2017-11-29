Firewall {
  require => Class['profile::fw::pre'],
  before  => Class['profile::fw::post'],
}
node default {
}
