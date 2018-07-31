class profile::web_services::apache (
  Hash            $website_defaults,
  Boolean         $enable_firewall     = true,
  Optional[Hash]  $website_hash        = undef,
  Boolean         $lb                  = true,
  Boolean         $export_host         = false,
) {

  class { '::apache':
    default_mods => false,
    mpm_module   => 'prefork',
  }
  include ::apache::mod::php
  include ::apache::mod::ssl

  if $website_hash {
    $website_hash.each |String $site_name, Hash $website| {
      if $website['database_search'] {
        $search_results = puppetdb_query("resources[count()] {type = \"Mysql_database\" and title = \"${website['database_search']}\"}")[0]['count']
      } else {
        $_bypass = true
      }

      if $website['repo_provider'] == 'git' {
        ensure_packages(['git'])
      }

      if $_bypass or ($search_results != 0) {
        $_docroot = "/var/www/${website['docroot']}"

        $website_port = $website[port]

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
        if $enable_firewall and !defined(Firewall["100 ${facts['fqdn']} HTTP ${website_port}"]) {
          # add firewall rules
          firewall { "100 ${facts['fqdn']} HTTP ${website_port}":
            dport  => $website['port'],
            proto  => tcp,
            action => accept,
          }
        }

        # Export monitoring configuration
        @@nagios_service { "${facts['fqdn']}_http_${site_name}":
          ensure              => present,
          use                 => 'generic-service',
          host_name           => $facts['fqdn'],
          service_description => "${facts['fqdn']}_http_${site_name}",
          check_command       => "check_http!${site_name} -I ${facts['networking']['ip']} -p ${website_port} -u http://${site_name}",
          target              => "/etc/nagios/conf.d/${facts['fqdn']}_service.cfg",
          notify              => Service['nagios'],
          require             => File["/etc/nagios/conf.d/${facts['fqdn']}_service.cfg"],
        }

        apache::vhost { $site_name:
          docroot        => $_docroot,
          manage_docroot => $website[manage_docroot],
          port           => $website[port],
          priority       => $website[priority],
        }

        if $website[repo_source] {
          vcsrepo { $site_name:
            ensure   => present,
            path     => $_docroot,
            provider => $website[repo_provider],
            source   => $website[repo_source],
            require  => Apache::Vhost[$site_name],
          }
        } elsif $website[site_package] {
          package { $website[site_package]:
            ensure => present,
            tag    => 'custom',
          }
        }
        # Exported load balancer configuration if required
        if $lb {
          @@haproxy::balancermember { "${site_name}-${facts['fqdn']}":
            listening_service => $site_name,
            server_names      => $facts['fqdn'],
            ipaddresses       => $facts['networking']['ip'],
            ports             => $website[port],
            options           => 'check',
          }
        }
      }
    }
  }
}
