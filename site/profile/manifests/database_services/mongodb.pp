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
  Optional[Sensitive[String[1]]] $cluster_auth_pem_content,
  Optional[Sensitive[String[1]]] $pem_file_content,
  Optional[String[1]]            $ca_cert_pem_content,
  Optional[Stdlib::Absolutepath] $pki_dir,
  Optional[Stdlib::Absolutepath] $ca_file_path,
  Optional[Stdlib::Absolutepath] $pem_file_path,
  Optional[Stdlib::Absolutepath] $cluster_auth_file_path,
  String[1]                      $svc_user,
) {

  require mongodb::repos
  require mongodb::os
  require mongodb::user

  class { 'mongodb::install':
    base_path    => $base_path,
    db_base_path => $db_base_path,
    log_path     => $log_path,
    pki_path     => $pki_path,
  }

  class { mongodb::supporting:
    cluster_auth_pem_content => $cluster_auth_pem_content,
    pem_file_content         => $pem_file_content,
    ca_cert_pem_content      => $ca_cert_pem_content,
    pki_dir                  => $pki_dir,
    ca_file_path             => $ca_file_path,
    pem_file_path            => $pem_file_path,
    cluster_auth_file_path   => $cluster_auth_file_path,
    svc_user                 => $svc_user,
    before                   => Mongodb::Service[$instance_name],
  }

  $mongod_instance.each |String $instance_name, Hash $instance_data| {
    mongodb::config { $instance_name:
      *      => $instance_data,
      before => Mongodb::Service[$instance_name],
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
