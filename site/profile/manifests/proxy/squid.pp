class profile::proxy::squid (
  Hash $firewall_rule_defaults,
  Hash $https_ports,
  Hash $http_ports,
  Hash $acls,
  Hash $http_accesses,
  Boolean $enable_firewall        = true,
  Optional[Hash] $extra_configs   = {},
  Optional[Hash] $firewall_rules  = {},
) {

  if $enable_firewall {
    if $firewall_rules {
      $firewall_rules.each |String $rule_name, Hash $rule_data| {
        firewall { $rule_name:
          *   => $rule_data;
          default:
            * => $firewall_rule_defaults,
        }
      }
    }
  }

  include squid

  $extra_configs.each |String $extra_config_name, Hash $extra_config_data| {
    squid::extra_config_section { $extra_config_name:
      * => $extra_config_data
    }
  }

  $acls.each |String $acl_name, Hash $acl_data| {
    squid::acl { $acl_name:
      * => $acl_data,
    }
  }

  $http_accesses.each |String $http_access_name, Hash $http_access_data| {
    squid::http_access { $http_access_name:
      * => $http_access_data,
    }
  }

  $http_ports.each |String $http_port_name, Hash $http_port_data| {
    squid::http_port { $http_port_name:
      * => $http_port_data,
    }
  }

  $https_ports.each |String $https_port_name, Hash $https_port_data| {
    squid::https_port { $https_port_name:
      * => $https_port_data,
    }
  }

  squid::ssl_bump { 'all':
    action => 'bump',
  }
}
