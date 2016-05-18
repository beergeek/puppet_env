class profile::web_services {

  $website_hash 	    = hiera('profile::web_services::website_hash')
  $website_defaults 	= hiera('profile::web_services::website_defaults')
  $enable_firewall    = hiera('profile::web_services::enable_firewall')
  $lb                 = hiera('profile::web_services::lb', true)

  #build base web server
  case $::kernel {
    'linux': {
      require apache
      require apache::mod::php
      require apache::mod::ssl
      include app_update

      if $enable_firewall {
        # add firewall rules
        firewall { '100 allow http and https access':
          port   => [80, 443],
          proto  => tcp,
          action => accept,
        }
      }

    }
    'windows': {
      include iis

      # disable default website
      iis::manage_site { 'Default Web Site':
        ensure    => absent,
        site_path => 'C:\inetpub\wwwroot',
        app_pool  => 'Default Web Site',
      }

      iis::manage_app_pool { 'Default Web Site':
        ensure => absent,
      }
    }
    default: {
      fail("${::kernel} is a non-supported OS Kernel")
    }
  }

  #create web sites
  # old school
  # create_resources('profile::web_sites',$website_hash,$website_defaults)
  # new school
  $website_hash.each |String $site_name, Hash $site_hash| {
    profile::web_sites { $site_name:
      * => $site_hash,;
      default:
        * => $website_defaults,;
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
