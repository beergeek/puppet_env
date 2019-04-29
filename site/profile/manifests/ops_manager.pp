#
class profile::ops_manager (
  Boolean       $ops_manager_ssl,
  String[1]     $gen_key_file_content,
  String[1]     $appsdb_uri,
  String[1]     $admin_email_addr,
  Stdlib::Host  $email_hostname,
  String[1]     $from_email_addr,
  String[1]     $reply_email_addr,
) {

notify { $admin_email_addr: }

  #class { 'mongodb::ops_manager':
  #  ops_manager_ssl       => $ops_manager_ssl,
  #  gen_key_file_content  => $gen_key_file_content,
  #  appsdb_uri            => $appsdb_uri,
  #  admin_email_addr      => $admin_email_addr,
  #  email_hostname        => $email_hostname,
  #  from_email_addr       => $from_email_addr,
  #  reply_email_addr      => $reply_email_addr,
  #}
}
