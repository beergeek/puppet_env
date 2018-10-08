class profile::tomcat_services (
  Hash $tomcat_installs,
  Hash $tomcat_servers,
  Hash $tomcat_instances,
  Hash $tomcat_connectors,
) {

  class { 'java': }

  $tomcat_installs.each |String $install_name, Hash $install_info| {
    tomcat::install { $install_name:
      * => $install_info,
    }
  }

  $tomcat_instances.each |String $instance_name, Hash $instance_info| {
    tomcat::config::instance { $instance_name:
      * => $instance_info,;
    }
  }

  $tomcat_servers.each |String $server_name, Hash $server_info| {
    tomcat::config::server { $server_name:
      * => $server_info,
    }
  }

  $tomcat_connectors.each |String $connector_name, Hash $connector_info| {
    tomcat::config::server::connector { $connector_name:
      * => $connector_info,
    }
  }
}
