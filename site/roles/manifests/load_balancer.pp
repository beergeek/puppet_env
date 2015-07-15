class roles::load_balancer {

  require profiles::base
  include profiles::lb_services

}
