class profile::web_services::iis (
  Optional[Hash] $website_hash = undef,
  Boolean $lb                  = true,
  Boolean $export_host         = false,
) {


  require ::iis

  # remove default site
  ::iis::website { 'Default Web Site':
    ensure => 'Absent',
  }

  if $website_hash {
    $website_hash.each |String $site_name, Hash $website| {
      if $website['database_search'] {
        $search_results = puppetdb_query("resources[count()] {type = \"Sqlserver::Database\" and title = \"${website['database_search']}\"}")[0]['count']
      } else {
        $_bypass = true
      }
      if $_bypass or ($search_results != 0) {

        if $export_host {
          @@host { $site_name:
            ensure => present,
            ip     => $facts['networking']['ip'],
          }
        } else {
          host { $site_name:
            ensure => present,
            ip     => $facts['networking']['ip'],
          }
        }

        iis::website { $site_name:
          * => $website,
        }

        $website['binding_hash'].each |Hash $binding| {
          if !defined(Windows_firewall::Exception["HTTP - ${binding['port']}"]) {
            windows_firewall::exception { "HTTP - ${binding['port']}":
              ensure       => present,
              direction    => 'in',
              action       => 'Allow',
              enabled      => 'yes',
              protocol     => 'TCP',
              local_port   => $binding['port'],
              remote_port  => 'any',
              display_name => 'HTTP - inbound',
              description  => 'Inbound rule for Interstroodle',
            }
          }

          # Exported load balancer configuration if required
          if $lb {
            @@haproxy::balancermember { "${site_name}-${facts['fqdn']}":
              listening_service => $site_name,
              server_names      => $facts['fqdn'],
              ipaddresses       => $facts['networking']['ip'],
              ports             => $binding['port'],
              options           => 'check',
            }
          }

          # Export monitoring configuration
          @@nagios_service { "${facts['fqdn']}_http_${site_name}":
            ensure              => present,
            use                 => 'generic-service',
            host_name           => $facts['fqdn'],
            service_description => "${facts['fqdn']}_http_${site_name}",
            check_command       => "check_http!${site_name} -I ${facts['networking']['ip']} -p ${binding['port']} -u http://${site_name}",
            target              => "/etc/nagios/conf.d/${facts['fqdn']}_service.cfg",
            notify              => Service['nagios'],
            require             => File["/etc/nagios/conf.d/${facts['fqdn']}_service.cfg"],
          }
        }
      }
    }
  }
}
