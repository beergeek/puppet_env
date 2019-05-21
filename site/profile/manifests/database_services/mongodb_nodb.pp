#
# Remember '/etc/krb5.conf'!
class profile::database_services::mongodb_nodb (
  Array[String[1]]               $firewall_ports,
  Boolean                        $enable_firewall,
  Boolean                        $enable_ssl,
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
  Sensitive[String[1]]           $mms_api_key,
  Stdlib::Absolutepath           $base_path,
  Stdlib::Absolutepath           $db_base_path,
  Stdlib::Absolutepath           $log_path,
  String[1]                      $mms_group_id,
  String[1]                      $ops_manager_fqdn,
  String[1]                      $svc_user,
  Optional[String[1]]            $aa_ca_cert_content    = $ca_cert_pem_content,
) {
  require mongodb::os
  require mongodb::user

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


  if $server_keytab_path {
    require profile::kerberos
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
