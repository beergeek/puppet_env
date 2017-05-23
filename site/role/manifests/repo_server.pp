class role::repo_server {

  require profile::base
  include profile::web_services
  include profile::repo_server

}
