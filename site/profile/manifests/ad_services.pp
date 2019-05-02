# Profile for Active Directory Domain Controllers
class profile::ad_services (
  Hash    $domain_controller_hash,
  Hash    $dns_server_hash,
  Boolean $collect_hosts          = true,
  #Hash $dns_forwardzones = {},
) {

  class { 'active_directory::domain_controller':
    * => $domain_controller_hash,
  }

  class { 'active_directory::dns_server':
    * => $dns_server_hash,
  }

  if $collect_hosts {
    Dsc_xdnsrecord <<| |>>
  }

}
