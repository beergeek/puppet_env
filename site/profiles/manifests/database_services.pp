class profiles::database_services {

  $db_hash     = hiera_hash('profiles::database_services::db_hash')
  $db_defaults = hiera('profiles::database_services::db_defaults')
  $enable_firewall = hiera('profiles::database_services::enable_firewall')

  case $::kernel {
    'linux': {
      require mysql::server
      class {'mysql::bindings':
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
          port   => [3306],
          proto  => tcp,
          action => accept,
        }
      }
    }
    'windows': {

      #create service
      sqlserver_instance{'MSSQLSERVER':
          features                => ['SQL'],
          source                  => 'E:/',
          sql_sysadmin_accounts   => ['dbuser'],
      }
      sqlserver_features { 'Generic Features':
        source    => 'E:/',
        features  => ['ADV_SSMS', 'BC', 'Conn', 'SDK', 'SSMS'],
      }

      $db_hash.each |$key, $value| {
        sqlserver::database { $key:
          instance => 'MSSQLSERVER',
        }
        sqlserver::login{ "${key}_login":
            password => 'Pupp3t1@',
        }

        sqlserver::user{ "${key}_user":
            user     => "${key}_user",
            database => $key,
            require  => Sqlserver::Login["${key}_login"],
        }
      }
    }
    default: {
      fail("${::kernel} is not a support OS kernel")
    }
  }
}
