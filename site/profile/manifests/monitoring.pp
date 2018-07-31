class profile::monitoring (
  Boolean $noop_scope = false,
) {

  if $facts['brownfields'] and $noop_scope {
    noop(true)
  } else {
    unless $::settings::noop { noop(false) }
  }

  if $facts['kernel'] == 'Linux' {
    case $facts['os']['family'] {
      'redhat':{
        require epel
        package { ['nagios-common','nrpe']:
          ensure => present,
        }

        service { 'nrpe':
          ensure => running,
          enable => true,
        }
      }
      'debain': {
        package { 'nagios-nrpe-server':
          ensure => present,
        }

        service { 'nagios-nrpe-server':
          ensure => running,
          enable => true,
        }
      }
    }

    firewall { '101 accept NRPE':
      proto  => 'tcp',
      dport  => '5666',
      action => 'accept',
    }
  }

  @@file { ["/etc/nagios/conf.d/${facts['fqdn']}_host.cfg","/etc/nagios/conf.d/${facts['fqdn']}_service.cfg"]:
    ensure => file,
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0400',
    tag    => 'Monitoring',
  }

  @@nagios_host { $facts['fqdn']:
    ensure             => present,
    alias              => $facts['hostname'],
    address            => $facts['ipaddress_eth1'],
    use                => 'generic-host',
    max_check_attempts => '4',
    check_command      => 'check-host-alive',
    target             => "/etc/nagios/conf.d/${facts['fqdn']}_host.cfg",
    notify             => Service['nagios'],
    require            => File["/etc/nagios/conf.d/${facts['fqdn']}_host.cfg"],
  }
}
