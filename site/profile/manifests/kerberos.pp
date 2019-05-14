#
class profile::kerberos (
  String[1]     $default_realm,
  Stdlib::Fqdn  $kdc_server,
  Stdlib::Fqdn  $admin_server,
) {

  file { '/etc/krb5.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    content => epp('profile/krb5.conf.epp', {
      default_realm => $default_realm,
      kdc_server    => $kdc_server,
      admin_server  => $admin_server,
    }),
  }
}
