class profile::database_services::mysql (
  Hash $db_hash,
  Hash $db_defaults,
  Boolean $enable_firewall = true,
) {

  class { '::mysql::server':
    override_options => {
      'mysqld' => {
        'bind-address' => '0.0.0.0',
      }
    }
  }
  class {'::mysql::bindings':
    php_enable => true,
  }

  # create databases (old)
  # create_resources('mysql::db',$db_hash,$db_defaults)
  # create databases (new)
  $db_hash.each |String $database_name, Hash $database_hash| {
    mysql::db {  $database_name:
      * => $database_hash,;
    default:
      * => $db_defaults,;
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

  @@nagios_service { "${::fqdn}_mysql":
    ensure              => present,
    use                 => 'generic-service',
    host_name           => $::fqdn,
    service_description => "MySQL",
    check_command       => 'check_tcp!3306',
    target              => "/etc/nagios/conf.d/${::fqdn}_service.cfg",
    notify              => Service['nagios'],
    require             => File["/etc/nagios/conf.d/${::fqdn}_service.cfg"],
  }
}
