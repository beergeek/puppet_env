#
# Remember '/etc/krb5.conf'!
class profile::database_services::mongodb_nodb (
  Array[String[1]]               $firewall_ports,
  Boolean                        $enable_firewall,
  Boolean                        $enable_ssl,
  Boolean                        $manage_ldap,
  Boolean                        $manage_kerberos,
  Enum['http','https']           $url_svc_type,
  Optional[Sensitive[String[1]]] $aa_pem_file_content,
  Optional[Sensitive[String[1]]] $cluster_auth_pem_content,
  Optional[Sensitive[String[1]]] $keyfile_content,
  Optional[Sensitive[String[1]]] $pem_file_content,
  Optional[Sensitive[String[1]]] $server_keytab_content,
  Optional[Stdlib::Absolutepath] $aa_ca_file_path,
  Optional[Stdlib::Absolutepath] $aa_pem_file_path,
  Optional[Stdlib::Absolutepath] $ca_file_path,
  Optional[Stdlib::Absolutepath] $cluster_auth_file_path,
  Optional[Stdlib::Absolutepath] $pem_file_path,
  Optional[Stdlib::Absolutepath] $pki_path,
  Optional[Stdlib::Absolutepath] $server_keytab_path,
  Optional[String[1]]            $ca_cert_pem_content,
  Optional[Sensitive[String[1]]] $mms_api_key,
  Stdlib::Absolutepath           $base_path,
  Stdlib::Absolutepath           $db_base_path,
  Stdlib::Absolutepath           $log_path,
  String[1]                      $mms_group_id,
  String[1]                      $ops_manager_fqdn,
  String[1]                      $svc_user,
  Optional[String[1]]            $aa_ca_cert_content    = $ca_cert_pem_content,
  Optional[Struct[{
    log_processor_dir       => Stdlib::Absolutepath,
    Optional[script_owner]  => String[1],
    Optional[script_group]  => String[1],
    Optional[script_mode]   => String[1],
  }]] $log_processor_install_hash,
  Optional[Hash[
    String[1],
    Struct[{
      audit_db_connection_string           => String[1],
      log_processor_dir                    => Stdlib::Absolutepath,
      Optional[config_file_path]           => Stdlib::Absolutepath,
      Optional[log_file_path]              => Stdlib::Absolutepath,
      Optional[enable_audit_db_ssl]        => Boolean,
      Optional[enable_debugging]           => Boolean,
      Optional[enable_kerberos_debugging]  => Boolean,
      Optional[elevated_ops_events]        => Array[String[1]],
      Optional[elevated_app_events]        => Array[String[1]],
      Optional[elevated_config_events]     => Array[String[1]],
      Optional[kerberos_keytab_path]       => Stdlib::Absolutepath,
      Optional[kerberos_trace_path]        => Stdlib::Absolutepath,
      Optional[audit_db_ssl_pem_file_path] => Stdlib::Absolutepath,
      Optional[audit_db_ssl_ca_file_path]  => Stdlib::Absolutepath,
      Optional[audit_log]                  => Stdlib::Absolutepath,
      Optional[python_path]                => Stdlib::Absolutepath,
      Optional[script_owner]               => String[1],
      Optional[script_group]               => String[1],
      Optional[audit_db_timeout]           => Integer,
    }]
  ]] $log_processor_config_hash,
) {
  require mongodb::os

  if $enable_firewall {
    $firewall_ports.each |String $_port| {
    # firewall rules
      firewall { "101 allow mongodb ${_port} access":
        dport  => [$_port],
        proto  => tcp,
        action => accept,
      }
    }
  }


  if $manage_kerberos {
    require profile::kerberos
  }

  if $manage_ldap {
    require profile::ldap
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

  if $mms_api_key {
    class { 'mongodb::automation_agent':
      ops_manager_fqdn => $ops_manager_fqdn,
      url_svc_type     => $url_svc_type,
      mms_group_id     => $mms_group_id,
      mms_api_key      => $mms_api_key,
      enable_ssl       => $enable_ssl,
      ca_file_path     => $aa_ca_file_path,
      pem_file_path    => $aa_pem_file_path,
      pem_file_content => $aa_pem_file_content,
      ca_file_content  => $aa_ca_cert_content,
    }
  }

  if $log_processor_config_hash {
    class { 'mongodb_audit_tools::log_processor::install':
      * => $log_processor_install_hash,
    }

    $log_processor_config_hash.each |String $log_processor_name, Hash $log_processor_data| {
      mongodb_audit_tools::log_processor { $log_processor_name:
        *       => $log_processor_data,
        require => Class['mongodb::supporting'],
      }
    }
  }
}
