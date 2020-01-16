#
class profile::ops_manager (
  Boolean                                      $enable_firewall,
  String                                       $port,
  String                                       $central_url,
  Boolean                                      $manage_ca,
  Boolean                                      $manage_pem,
  Boolean                                      $ops_manager_ssl,
  Boolean                                      $installer_autodownload_ent,
  Boolean                                      $installer_autodownload,
  Enum['mongodb','hybrid','local']             $installer_source,
  Enum['none','agents_only','required']        $client_cert_mode,
  Optional[Stdlib::Absolutepath]               $ca_cert_path,
  Optional[Stdlib::Absolutepath]               $pem_file_path,
  Optional[Stdlib::Filesource]                 $mms_source,
  Optional[String[1]]                          $ca_cert_content,
  Optional[Sensitive[String[1]]]               $pem_file_content,
  Stdlib::Host                                 $email_hostname,
  String[1]                                    $admin_email_addr,
  String[1]                                    $appsdb_uri,
  String[1]                                    $from_email_addr,
  Stdlib::Base64                               $gen_key_file_content,
  String[1]                                    $reply_email_addr,
  Enum['com.xgen.svc.mms.svc.user.UserSvcDb',
      'com.xgen.svc.mms.svc.user.UserSvcLdap',
      'com.xgen.svc.mms.svc.user.UserSvcSaml'] $auth_type,
  Optional[String]                             $ldap_bind_dn,
  Optional[Stdlib::Port]                       $ldap_url_port,
  Optional[Sensitive[String[1]]]               $ldap_bind_password,
  Optional[String[1]]                          $ldap_global_owner,
  Optional[Mongodb::LDAPUrl]                   $ldap_url_host,
  Optional[String[1]]                          $ldap_user_group,
  Optional[String[1]]                          $ldap_user_search_attribute,
  Optional[Stdlib::Absolutepath]               $auth_ssl_ca_file,
  Optional[Stdlib::Absolutepath]               $auth_ssl_pem_key_file,
  Optional[String[1]]                          $ldap_user_base_dn,
) {
  if $enable_firewall {
    # firewall rules
    firewall { '101 allow mongodb ops manager access':
      dport  => [$port],
      proto  => tcp,
      action => accept,
    }
  }

  class { 'mongodb::ops_manager':
    admin_email_addr           => $admin_email_addr,
    appsdb_uri                 => $appsdb_uri,
    ca_cert_content            => $ca_cert_content,
    ca_cert_path               => $ca_cert_path,
    central_url                => $central_url,
    client_cert_mode           => $client_cert_mode,
    email_hostname             => $email_hostname,
    from_email_addr            => $from_email_addr,
    gen_key_file_content       => $gen_key_file_content,
    installer_autodownload     => $installer_autodownload,
    installer_autodownload_ent => $installer_autodownload_ent,
    installer_source           => $installer_source,
    manage_ca                  => $manage_ca,
    manage_pem                 => $manage_pem,
    ops_manager_ssl            => $ops_manager_ssl,
    pem_file_content           => $pem_file_content,
    pem_file_path              => $pem_file_path,
    reply_email_addr           => $reply_email_addr,
    auth_type                  => $auth_type,
    ldap_bind_dn               => $ldap_bind_dn,
    ldap_url_port              => $ldap_url_port,
    ldap_bind_password         => $ldap_bind_password,
    ldap_global_owner          => $ldap_global_owner,
    ldap_url_host              => $ldap_url_host,
    ldap_user_group            => $ldap_user_group,
    ldap_user_search_attribute => $ldap_user_search_attribute,
    ldap_user_base_dn          => $ldap_user_base_dn,
    auth_ssl_ca_file           => $auth_ssl_ca_file,
    auth_ssl_pem_key_file      => $auth_ssl_pem_key_file,
  }
}
