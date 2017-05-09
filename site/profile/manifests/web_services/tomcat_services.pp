class profile::tomcat_services (
  $tomcat_servers,
) {

  class { 'tomcat': }

  $tom_instances.each |String $server_name, Hash $server_info| {
    tomcat::config::instance { $server_name:
      * => $server_info,;
    }
  }
}
