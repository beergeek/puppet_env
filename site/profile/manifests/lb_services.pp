class profile::lb_services {

  @@host { 'puppet.puppetlabs.vm':
    ensure       => present,
    host_aliases => ['puppet'],
    ip           => $::ipaddress_eth1,
  }

  if $lb_type == 'f5' {
    include profile::lb_services::f5
  } else {
    include profile::lb_services::haproxy
  }

}
