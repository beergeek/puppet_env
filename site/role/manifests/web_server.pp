class role::web_server {

  require profile::base
  include profile::web_services
  include profile::puppet_users

}
