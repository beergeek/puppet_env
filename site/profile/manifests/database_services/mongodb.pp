#
# Remember '/etc/krb5.conf'!
class profile::database_services::mongodb (
  Boolean                        $enable_firewall   = true,
  Stdlib::Absolutepath           $base_path,
  Stdlib::Absolutepath           $db_base_path,
  Stdlib::Absolutepath           $log_path,
  Hash                           $mongod_instance   = {
    'appdb' => {
      port        => '27017',
      member_auth => 'none',
      ssl_mode    => 'none',
    },
  },
  Optional[Sensitive[String[1]]] $cluster_auth_pem_content,
  Optional[Sensitive[String[1]]] $pem_file_content,
  Optional[Sensitive[String[1]]] $keyfile_content,
  Optional[String[1]]            $ca_cert_pem_content,
  Optional[Stdlib::Absolutepath] $pki_path,
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
  Enum['http','https']           $url_svc_type,
  Optional[Stdlib::Absolutepath] $aa_ca_file_path,
  Optional[Stdlib::Absolutepath] $aa_pem_file_path,
  Optional[Sensitive[String[1]]] $aa_pem_file_content,
  Optional[String[1]]            $aa_ca_cert_content    = $ca_cert_pem_content,
) {

  require mongodb::repos
  require mongodb::os
  require mongodb::user

  class { 'mongodb::install':
  }

  class { 'mongodb::supporting':
    base_path                => $base_path,
    ca_cert_pem_content      => $ca_cert_pem_content,
    ca_file_path             => $ca_file_path,
    cluster_auth_file_path   => $cluster_auth_file_path,
    cluster_auth_pem_content => $cluster_auth_pem_content,
    db_base_path             => $db_base_path,
    log_path                 => $log_path,
    keyfile_content          => $keyfile_content,
    pem_file_content         => $pem_file_content,
    pem_file_path            => $pem_file_path,
    pki_path                 => $pki_path,
    server_keytab_content    => $server_keytab_content,
    server_keytab_path       => $server_keytab_path,
    svc_user                 => $svc_user,
  }

  $mongod_instance.each |String $instance_name, Hash $instance_data| {
    mongodb::config { $instance_name:
      *       => $instance_data,
      before  => Mongodb::Service[$instance_name],
      require => Class['mongodb::install'],
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
      require => Class['mongodb::supporting'],
    }
  }

  if $install_aa {
    class { 'mongodb::automation_agent':
      ops_manager_fqdn    => $ops_manager_fqdn,
      url_svc_type        => $url_svc_type,
      mms_group_id        => $mms_group_id,
      mms_api_key         => $mms_api_key,
      enable_ssl          => $enable_ssl,
      ca_file_path        => $aa_ca_file_path,
      pem_file_path       => $aa_pem_file_path,
      pem_file_content    => $aa_pem_file_content,
      ca_file_content     => $aa_ca_cert_content,
    }
  }

}
