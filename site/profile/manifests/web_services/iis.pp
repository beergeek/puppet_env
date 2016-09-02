class profile::web_services::iis {

  # Lookup website information and load balancer
  $website_hash = hiera('profile::web_services::iis::website_hash',undef)
  $base_docroot = hiera('profile::web_services::iis::base_docroot')
  $lb           = hiera('profile::web_services::iis::lb',true)
  $export_host  = hiera('profile::web_services::iis::export_host', false)

  # Get correct Features for IIS depending on Windows Version
  case $::kernelmajversion {
    '6.0','6.1': {
      $feature_name = [
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
    '6.2.','6.3': {
      $feature_name = [
        'Web-Server',
        'Web-WebServer',
        'Web-Common-Http',
        'Web-Asp',
        'Web-Asp-Net45',
        'Web-ISAPI-Ext',
        'Web-ISAPI-Filter',
        'Web-Http-Redirect',
        'Web-Health',
        'Web-Http-Logging',
        'Web-Filtering',
        'Web-Mgmt-Console',
        'Web-Mgmt-Tools'
        ]
    }
    default: {
      fail("You must be running a 19th centery version of Windows")
    }
  }

  Iis::Manage_site {
    require => Windowsfeature[$feature_name],
  }

  Iis::Manage_app_pool {
    require => Windowsfeature[$feature_name],
  }

  # Enable IIS
  windowsfeature { $feature_name:
    ensure => present,
  }

  # disable default website
  iis::manage_site { 'Default Web Site':
    ensure    => absent,
    site_path => 'C:\inetpub\wwwroot',
    app_pool  => 'Default Web Site',
  }

  iis::manage_app_pool { 'Default Web Site':
    ensure => absent,
  }

  if $website_hash {
    $website_hash.each |String $site_name, Hash $website| {
      if $website['database_search'] {
        $search_results = puppetdb_query({type = "Sqlserver::Database" and title = "${website['database_search']}"})
        #$search_results = query_resources(false, $website['database_search'])
      } else {
        $_bypass = true
      }
      if $_bypass or !(empty($search_results)) {
        $_docroot = "${base_docroot}\\${website['docroot']}"

        if $export_host {
          @@host { $site_name:
            ensure => present,
            ip     => $::networking['interfaces']['Ethernet 2']['ip'],
          }
        } else {
          host { $site_name:
            ensure => present,
            ip     => $::networking['interfaces']['Ethernet 2']['ip'],
          }
        }

        if !defined(Windows_firewall::Exception["HTTP - ${website['port']}"]) {
          windows_firewall::exception { "HTTP - ${website['port']}":
            ensure       => present,
            direction    => 'in',
            action       => 'Allow',
            enabled      => 'yes',
            protocol     => 'TCP',
            local_port   => $website['port'],
            remote_port  => 'any',
            display_name => 'HTTP - inbound',
            description  => 'Inbound rule for Interstroodle',
          }
        }

        # Export monitoring configuration
        @@nagios_service { "${::fqdn}_http_${site_name}":
          ensure              => present,
          use                 => 'generic-service',
          host_name           => $::fqdn,
          service_description => "${::fqdn}_http_${site_name}",
          check_command       => "check_http!${site_name} -I ${networking['interfaces']['Ethernet 2']['ip']} -p ${website['port']} -u http://${site_name}",
          target              => "/etc/nagios/conf.d/${::fqdn}_service.cfg",
          notify              => Service['nagios'],
          require             => File["/etc/nagios/conf.d/${::fqdn}_service.cfg"],
        }

        iis::manage_app_pool { $site_name:
          enable_32_bit           => true,
          managed_runtime_version => 'v4.0',
        }

        iis::manage_site { $site_name:
          site_path   => $_docroot,
          port        => $website['port'],
          ip_address  => '*',
          host_header => $site_name,
          app_pool    => $site_name,
          before      => File[$_docroot],
        }

        acl { $_docroot:
          target                     => $_docroot,
          purge                      => false,
          permissions                => [
            { identity => 'vagrant', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all' },
            { identity => 'Administrators', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all'}
            ],
            owner                      => 'vagrant',
            group                      => 'Administrators',
            inherit_parent_permissions => true,
        }
        file { $_docroot:
          ensure  => directory,
          owner   => 'vagrant',
          group   => 'Administrators',
          recurse => true,
          purge   => true,
          force   => true,
          source  => "puppet:///iis_files/${site_name}",
        }
        # Exported load balancer configuration if required
        if $lb {
          @@haproxy::balancermember { "${site_name}-${::fqdn}":
            listening_service => $site_name,
            server_names      => $::fqdn,
            ipaddresses       => $::networking['interfaces']['Ethernet 2']['ip'],
            ports             => $website['port'],
            options           => 'check',
          }
        }
      }
    }
  }
}
