class profile::database_services::mysql (
  Boolean $enable_firewall                    = true,
  Optional[Hash] $db_hash                     = undef,
  Optional[Hash] $mysql_server_override_data  = {},
  Optional[Hash] $mysql_client_override_data  = {},
  Optional[Hash] $yumrepo_data                = {},
) {

  $yumrepo_data.each |String $repo_name, Hash $repo_data| {
    yumrepo { $repo_name:
      *      => $repo_data,
      before => Class['::mysql::client','::mysql::server'],
    }
  }

  class { '::mysql::client':
    * => $mysql_client_override_data,
  }

  class { '::mysql::server':
    * => $mysql_server_override_data,
  }

  class {'::mysql::bindings':
    php_enable => true,
  }

  if $db_hash and ! empty($db_hash) {
    $db_hash.each |String $database_name, Hash $database_hash| {
      mysql::db {  $database_name:
        * => $database_hash,;
        default:
          ensure => present,;
      }
    }
  }

  if $enable_firewall {
    # firewall rules
    firewall { '101 allow mysql access':
      dport  => [3306],
      proto  => tcp,
      action => accept,
    }
  }

  @@nagios_service { "${facts['fqdn']}_mysql":
    ensure              => present,
    use                 => 'generic-service',
    host_name           => $facts['fqdn'],
    service_description => 'MySQL',
    check_command       => 'check_tcp!3306',
    target              => "/etc/nagios/conf.d/${facts['fqdn']}_service.cfg",
    notify              => Service['nagios'],
    require             => File["/etc/nagios/conf.d/${facts['fqdn']}_service.cfg"],
  }
}
