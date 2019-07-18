#
class profile::ops_manager (
  Boolean                          $enable_firewall    = true,
  String                           $port               = '8080',
  String                           $central_url        = "https://${facts['networking']['fqdn']}:8080",
  Boolean                          $manage_ca,
  Boolean                          $manage_pem,
  Boolean                          $ops_manager_ssl,
  Boolean                          $installer_autodownload_ent,
  Boolean                          $installer_autodownload,
  Enum['mongodb','hybrid','local'] $installer_source,
  Optional[Stdlib::Absolutepath]   $ca_cert_path,
  Optional[Stdlib::Absolutepath]   $pem_file_path,
  Optional[String[1]]              $ca_cert_content,
  Sensitive[Optional[String[1]]]   $pem_file_content,
  Stdlib::Host                     $email_hostname,
  String[1]                        $admin_email_addr,
  String[1]                        $appsdb_uri,
  String[1]                        $from_email_addr,
  String[1]                        $gen_key_file_content,
  String[1]                        $reply_email_addr,
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
  }
}
