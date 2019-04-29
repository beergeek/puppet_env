#
class profile::ops_manager (
  Boolean       $enable_firewall    = true,
  String        $port               = '8080',
  String        $central_url        = "http://${facts['networking']['fqdn']}:8080",
  Boolean       $ops_manager_ssl,
  String[1]     $gen_key_file_content,
  String[1]     $appsdb_uri,
  String[1]     $admin_email_addr,
  Stdlib::Host  $email_hostname,
  String[1]     $from_email_addr,
  String[1]     $reply_email_addr,
) {
  if $enable_firewall {
    # firewall rules
    firewall { "101 allow mongodb ops manager access":
      dport  => [$port],
      proto  => tcp,
      action => accept,
    }
  }

  class { 'mongodb::ops_manager':
    ops_manager_ssl       => $ops_manager_ssl,
    gen_key_file_content  => $gen_key_file_content,
    appsdb_uri            => $appsdb_uri,
    admin_email_addr      => $admin_email_addr,
    email_hostname        => $email_hostname,
    from_email_addr       => $from_email_addr,
    reply_email_addr      => $reply_email_addr,
    central_url           => $central_url,
  }
}
