class profile::tomcat_services {

  $tomcat_servers = hiera('profile::tomcat_services::tomcat_servers')

  class { 'tomcat': }

  $tom_instances.each |String $server_name, Hash $server_info| {
    tomcat::config::instance { $server_name:
      * => $server_info,;
    }
  }
}

profile::tomcat_services::tomcat_servers:
  'one':
    catalina_base: '/opt/catalina/one'
    port: '8080'
  'two':
    catalina_base: '/opt/catalina/two'
    port: '8081'
