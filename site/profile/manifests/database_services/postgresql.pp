class profile::database_services::postgresql (
  Hash $postgresql_default_config,
  Hash $postgresql_db_default_config,
  Optional[Hash] $postgresql_db = {},
  Optional[Hash] $postgresql_config = {},
) {

  class { 'postgresql::server':
    * => $postgresql_config,;
    default:
      * => $postgresql_default_config,;
  }

  $postgresql_db.each |String $postgresql_db_name, Hash $postgresql_db_data| {
    $postgresql::server::db { $postgresql_db_name:
      *   => $postgresql_db_name,;
      default:
        * => $postgresql_db_default_config,;
    }
  }


}
