class role::load_balancer {

  require profile::base
  include profile::lb_services

}
