class profiles::web_services {

  $website_hash 	    = hiera_hash('profiles::web_services::website_hash')
  $website_defaults 	= hiera('profiles::web_services::website_defaults')

  #build base web server
  if $::kernel == 'Linux' {
    require apache
    require apache::mod::php
    require apache::mod::ssl
  }

  #create web sites
  create_resources('profiles::web_sites',$website_hash,$website_defaults)

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

  # add firewall rules
  firewall { '100 allow http and https access':
    port   => [80, 443],
    proto  => tcp,
    action => accept,
  }

}
