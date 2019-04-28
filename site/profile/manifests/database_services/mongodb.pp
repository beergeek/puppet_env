#
class profile::database_services::mongodb (
  Boolean                        $enable_firewall   = true,
  Optional[Stdlib::Absolutepath] $base_path         = undef,
  Optional[Stdlib::Absolutepath] $db_base_path      = undef,
  Optional[Stdlib::Absolutepath] $log_path          = undef,
  Optional[Stdlib::Absolutepath] $pki_path          = undef,
  Hash                           $mongod_instance   = {
    'appdb' => {
      port        => '27017',
      member_auth => 'none',
      ssl_mode    => 'none',
    },
  },
) {

  require mongodb::repos
  require mongodb::os

  class { 'mongodb::install':
    base_path    => $base_path,
    db_base_path => $db_base_path,
    log_path     => $log_path,
    pki_path     => $pki_path,
  }

  $mongod_instance.each |String $instance_name, Hash $instance_data| {
    mongodb::config { $instance_name:
      * => $instance_data,
    }

    if $enable_firewall {
      if $instance_data['port'] {
        $_port = $instance_data['port']
      } else {
        $_port = '27017'
      }
      # firewall rules
      firewall { "101 allow mongodb ${instance_name} access":
        dport  => [$_port],
        proto  => tcp,
        action => accept,
      }
    }

    mongodb::service { $instance_name:
    }
  }

}
