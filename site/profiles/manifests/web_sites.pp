define profiles::web_sites (
  $docroot,
  $create_host      = false,
  $database_search  = false,
  $manage_docroot   = true,
  $port             = '80',
  $priority         = '10',
  $repo_provider    = git,
  $repo_source      = undef,
  $site_name        = $title,
  $site_package     = undef,
)
{

  if $database_search {
    $search_results = query_resources("Class['mysql::server']", $database_search)
  } else {
    $_bypass = true
  }

  if $_bypass or size($search_results) > 0 {
    case $::kernel {
      'linux': {
        if $repo_provider == 'git' {
          ensure_packages(['git'])

          Vcsrepo {
            require => Package['git'],
          }
        }

        $_docroot = "/var/www/${docroot}"

        apache::vhost { $site_name:
          docroot        => $_docroot,
          manage_docroot => $manage_docroot,
          port           => $port,
          priority       => $priority,
        }

        if $repo_source {
          vcsrepo { $site_name:
            ensure   => present,
            path     => $_docroot,
            provider => $repo_provider,
            source   => $repo_source,
            require  => Apache::Vhost[$site_name],
          }
        } elsif $site_package {
          package { $site_package:
            ensure => present,
            tag    => 'custom',
          }
        }
      }
      'windows': {
        $_docroot = "C:\\inetpub\\wwwroot\\${docroot}"

        iis::manage_app_pool { $site_name:
          enable_32_bit           => true,
          managed_runtime_version => 'v4.0',
        }
         iis::manage_site { $site_name:
          site_path   => $_docroot,
          port        => '80',
          ip_address  => '*',
          host_header => $site_name,
          app_pool    => $site_name,
          before      => File[$site_name],
        }

        file { $site_name:
          ensure  => directory,
          path    => $_docroot,
        }

        acl { $_docroot:
          target                     => $_docroot,
          purge                      => false,
          permissions                => [
           { identity => 'Administrator', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all' },
           { identity => 'Administrators', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all'}
          ],
          owner                      => 'Administrators',
          group                      => 'Administrator',
          inherit_parent_permissions => true,
        }
        file { "${site_name}_index":
          ensure  => file,
          path    => "${_docroot}\\index.html",
          owner   => 'Administrator',
          group   => 'Administrators',
          mode    => '0644',
          content => "${site_name} - hello",
        }
      }
    }

    if $create_host {
      @@host {$site_name:
        ensure => present,
        ip     => $::ipaddress_eth1,
      }
    }
  }
}
