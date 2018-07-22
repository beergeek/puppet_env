class profile::mom (
  Hash           $firewall_rule_defaults,
  Optional[Hash] $firewall_rules          = {},
  Boolean        $enable_firewall         = true,
) {

  package { 'autosign':
    ensure   => present,
    provider => 'puppet_gem',
    notify   => Exec['setup_autosign'],
  }

  exec { 'setup_autosign':
    command => 'autosign config setup',
    path    => '/opt/puppetlabs/puppet/bin',
    creates => '/etc/autosign.conf',
  }

  if $enable_firewall {
    if $firewall_rules {
      $firewall_rules.each |String $rule_name, Hash $rule_data| {
        firewall { $rule_name:
          *   => $rule_data;
          default:
            * => $firewall_rule_defaults,
        }
      }
    }
  }

  @@nagios_service { "${facts['fqdn']}_puppet":
    ensure              => present,
    use                 => 'generic-service',
    host_name           => $facts['fqdn'],
    service_description => "Puppet Master",
    check_command       => 'check_http! -p 8140 -S -u /production/node/test',
    target              => "/etc/nagios/conf.d/${facts['fqdn']}_service.cfg",
    notify              => Service['nagios'],
    require             => File["/etc/nagios/conf.d/${facts['fqdn']}_service.cfg"],
  }

}
