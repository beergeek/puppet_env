class profiles::monitoring {

  require epel
  package { ['nagios','nagios-plugins','nrpe']:
    ensure => present,
  }

  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }

  firewall { '101 accept NRPE':
    proto  => 'tcp',
    port   => '5666',
    action => 'accept',
  }

  @@nagios_host { $::fqdn:
    ensure  => present,
    alias   => $::hostname,
    address => $::ipaddress_eth1,
    use     => "generic-host",
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0400',
    max_check_attempts => '4',
    target  => '/etc/nagios/conf.d/nagios_host.cfg',
  }
}
