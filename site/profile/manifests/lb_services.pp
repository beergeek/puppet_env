class profile::lb_services {

  if $lb_type == 'f5' {
    include profile::lb_services::f5
  } else {
    include profile::lb_services::haproxy
  }

}
