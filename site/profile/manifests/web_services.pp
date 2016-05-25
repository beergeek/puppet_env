class profile::web_services {

  $lb = hiera('profile::web_services::lb', true)

  case $::kernel {
    'linux': {
      include profile::web_services::apache
    }
    'windows': {
      include profile::web_services::iis
    }
    default: {
      fail("${::kernel} is a non-supported OS Kernel")
    }
  }

  # Export monitoring configuration
  @@nagios_service { "${::fqdn}_http":
    ensure              => present,
    use                 => 'generic-service',
    host_name           => $::fqdn,
    service_description => "HTTP",
    check_command       => 'check_http',
    target              => "/etc/nagios/conf.d/${::fqdn}_service.cfg",
    notify              => Service['nagios'],
    require             => File["/etc/nagios/conf.d/${::fqdn}_service.cfg"],
  }

  # Exported load balancer configuration if required
  if $lb {
    @@haproxy::balancermember { "http00-${::fqdn}":
      listening_service => 'http00',
      server_names      => $::fqdn,
      ipaddresses       => $::ipaddress_eth1,
      ports             => '80',
      options           => 'check',
    }
    @@haproxy::balancermember { "https00-${::fqdn}":
      listening_service => 'https00',
      server_names      => $::fqdn,
      ipaddresses       => $::ipaddress_eth1,
      ports             => '443',
      options           => 'check',
    }
  }

}
