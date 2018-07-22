# Profile for Active Directory Domain Controllers
class profile::ad_services (
  Hash $domain_controller_hash,
  Hash $dns_server_hash,
  #Hash $dns_forwardzones = {},
) {

  class { 'active_directory::domain_controller':
    * => $domain_controller_hash,
  }

  class { 'active_directory::dns_server':
    * => $dns_server_hash,
  }

  # Would love to use this, but there is an rror with DSC xDNSServer https://github.com/PowerShell/xDnsServer/issues/53
  #$dns_forwardzones.each |String $forwardzone_name, Hash $forwardzone_data| {
  #  active_directory::dns_ad_forewardzone { $forwardzone_name:
  #    * => $forwardzone_data,
  #  }
  #}

}
