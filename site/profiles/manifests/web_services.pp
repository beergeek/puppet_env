class profiles::web_services {

  $website_hash 	    = hiera('profiles::web_services::website_hash')
  $website_defaults 	= hiera('profiles::web_services::website_defaults')
  $enable_firewall    = hiera('profiles::web_services::enable_firewall')
  $lb                 = hiera('profiles::web_services::lb', true)

  #build base web server
  case $::kernel {
    'linux': {
      require apache
      require apache::mod::php
      require apache::mod::ssl

      if $enable_firewall {
        # add firewall rules
        firewall { '100 allow http and https access':
          port   => [80, 443],
          proto  => tcp,
          action => accept,
        }
      }

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

    }
    'windows': {
      windowsfeature { 'IIS':
        feature_name => [
          'Web-Server',
          'Web-WebServer',
          'Web-Asp-Net',
          'Web-ISAPI-Ext',
          'Web-ISAPI-Filter',
          'NET-Framework',
          'WAS-NET-Environment',
          'Web-Http-Redirect',
          'Web-Filtering',
          'Web-Mgmt-Console',
          'Web-Mgmt-Tools'
        ]
      }
      windowsfeature { 'Web-WebServer':
        installsubfeatures => true,
      }
    }
    default: {
      fail("${::kernel} is a non-supported OS Kernel")
    }
  }

  #create web sites
  create_resources('profiles::web_sites',$website_hash,$website_defaults)

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
