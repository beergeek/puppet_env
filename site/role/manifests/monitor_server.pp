class role::monitor_server {

  require profile::base
  include profile::web_services
  include profile::monitor_server

}
