#
# Remember '/etc/krb5.conf'!
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
  Optional[Sensitive[String[1]]] $server_keytab_content,
  Optional[Stdlib::Absolutepath] $server_keytab_path,
  Optional[Sensitive[String[1]]] $client_keytab_content,
  Optional[Stdlib::Absolutepath] $client_keytab_path,

  # automation agent
  Boolean                        $install_aa,
  String[1]                      $mms_group_id,
  Sensitive[String[1]]           $mms_api_key,
  String[1]                      $ops_manager_fqdn,
  Enum['http','https']           $url_svc_type    = 'http',

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
    server_keytab_content    => $server_keytab_content,
    server_keytab_path       => $server_keytab_path,
    client_keytab_content    => $client_keytab_content,
    client_keytab_path       => $client_keytab_path,
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

    if $instance_data['spn'] {
      if $instance_data['svc_account'] {
        @@dsc_xadserviceprincipalname { $instance_data['spn']:
          ensure      => present,
          dsc_account => $instance_data['svc_account'],
        }
      } else {
        fail('A service account is required to create a SPN')
      }
    }

    mongodb::service { $instance_name:
    }
  }

  if $install_aa {
    class { mongodb::automation_agent::install:
      ops_manager_fqdn => $ops_manager_fqdn,
      url_svc_type     => $url_svc_type,
    }
    class { mongodb::automation_agent::config:
      mms_group_id     => $mms_group_id,
      mms_api_key      => $mms_api_key,
      ops_manager_fqdn => $ops_manager_fqdn,
      url_svc_type     => $url_svc_type,
      require          => Class['mongodb::automation_agent::install']
    }
    class { mongodb::automation_agent::service:
      subscribe => Class['mongodb::automation_agent::config'],
    }
  }

}
