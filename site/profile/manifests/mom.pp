class profile::mom (
  Hash           $firewall_rule_defaults,
  Optional[Hash] $firewall_rules          = {},
  Boolean        $enable_firewall         = true,
) {

  Pe_hocon_setting {
    ensure => present,
    notify => Service["pe-puppetserver"],
  }

  include puppet_metrics_collector

  class { 'autosign':
    before   => Exec['setup_autosign'],
  }

  pe_hocon_setting { 'file-sync.repos.dump.live-dir':
    path    => "${confdir}/conf.d/file-sync.conf",
    setting => 'file-sync.repos.dump.live-dir',
    value   => '/opt/dump',
  }

  pe_hocon_setting { 'file-sync.repos.dump.submodules-dir':
    path    => "${confdir}/conf.d/file-sync.conf",
    setting => 'file-sync.repos.dump.submodules-dir',
    value   => '.',
  }

  pe_hocon_setting { 'file-sync.repos.dump.staging-dir':
    path    => "${confdir}/conf.d/file-sync.conf",
    setting => 'file-sync.repos.dump.staging-dir',
    value   => '/etc/puppetlabs/code-staging',
  }

  cron { 'puppet_backup':
    ensure  => present,
    command => '/opt/puppetlabs/bin/puppet backup create --scope certs,config,puppetdb',
    user    => 'root',
    weekday => $backup_cron_weekday,
    hour    => $backup_cron_hour,
    minute  => $backup_cron_minute,
  }

  exec { 'setup_autosign':
    command => 'autosign config setup',
    path    => '/opt/puppetlabs/puppet/bin',
    creates => '/etc/puppetlabs/puppetserver/autosign.conf',
  }

  ini_setting {'policy-based autosigning':
    ensure  => present,
    setting => 'autosign',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    value   => '/opt/puppetlabs/puppet/bin/autosign-validator',
    require => Exec['setup_autosign'],
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
    service_description => 'Puppet Master',
    check_command       => 'check_http! -p 8140 -S -u /production/node/test',
    target              => "/etc/nagios/conf.d/${facts['fqdn']}_service.cfg",
    notify              => Service['nagios'],
    require             => File["/etc/nagios/conf.d/${facts['fqdn']}_service.cfg"],
  }

}
