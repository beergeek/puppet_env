class profile::monitoring {

  $noop_scope = hiera('profile::base::noop_scope', false)

  if $::brownfields and $noop_scope {
    noop()
  }
  if $::kernel == 'Linux' {
    require epel
    package { ['nagios-common','nrpe']:
      ensure => present,
    }

    service { 'nrpe':
      ensure => running,
      enable => true,
    }

    firewall { '101 accept NRPE':
      proto  => 'tcp',
      port   => '5666',
      action => 'accept',
    }
  }

  @@file { ["/etc/nagios/conf.d/${::fqdn}_host.cfg","/etc/nagios/conf.d/${::fqdn}_service.cfg"]:
    ensure => file,
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0400',
    tag    => 'Monitoring',
  }

  @@nagios_host { $::fqdn:
    ensure             => present,
    alias              => $::hostname,
    address            => $::ipaddress_eth1,
    use                => "generic-host",
    max_check_attempts => '4',
    check_command      => 'check-host-alive',
    target             => "/etc/nagios/conf.d/${::fqdn}_host.cfg",
    notify             => Service['nagios'],
    require            => File["/etc/nagios/conf.d/${::fqdn}_host.cfg"],
  }
}
