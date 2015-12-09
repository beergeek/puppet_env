class roles::web_server {

  require profiles::base
  include profiles::web_services
  include profiles::puppet_users

}
