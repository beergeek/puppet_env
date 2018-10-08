class profile::tomcat_services (
  Hash           $tomcat_installs,
  Optional[Hash] $tomcat_servers    = undef,
  Optional[Hash] $tomcat_instances  = undef,
  Optional[Hash] $tomcat_connectors = undef,
) {

  class { 'java': }

  $tomcat_installs.each |String $install_name, Hash $install_info| {
    tomcat::install { $install_name:
      * => $install_info,
    }
  }

  if $tomcat_instances {
    $tomcat_instances.each |String $instance_name, Hash $instance_info| {
      tomcat::instance { $instance_name:
        * => $instance_info,;
      }
    }
  }

  if $tomcat_servers {
    $tomcat_servers.each |String $server_name, Hash $server_info| {
      tomcat::config::server { $server_name:
        * => $server_info,
      }
    }
  }

  if $tomcat_connectors {
    $tomcat_connectors.each |String $connector_name, Hash $connector_info| {
      tomcat::config::server::connector { $connector_name:
        * => $connector_info,
      }
    }
  }
}
