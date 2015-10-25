define profiles::web_sites (
  $docroot,
  $priority         = '10',
  $site_name        = $title,
  $port             = '80',
  $repo_source      = undef,
  $repo_provider    = git,
  $database_search  = false,
)
{

  if $database_search {
    $search_results = query_facts("Class['mysql']", $database_search)
  } else {
    $search_results = true
  }

  if $search_results {
    apache::vhost {$site_name:
      priority => $priority,
      port     => $port,
      docroot  => $docroot,
    }

    if $repo_source {
      vcsrepo { $site_name:
        ensure   => present,
        path     => $docroot,
        provider => $repo_provider,
        source   => $repo_source,
        require  => Apache::Vhost[$site_name],
      }
    }

    host {$site_name:
      ensure => present,
      ip     => $::ipaddress,
    }
  }
}
