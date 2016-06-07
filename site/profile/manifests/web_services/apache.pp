class profile::web_services::apache {

  $website_hash 	    = hiera('profile::web_services::apache::website_hash')
  $website_defaults 	= hiera('profile::web_services::apache::website_defaults')
  $enable_firewall    = hiera('profile::web_services::apache::enable_firewall')

  include ::apache
  include ::apache::mod::php
  include ::apache::mod::ssl
  include app_update

  if $enable_firewall {
    # add firewall rules
    firewall { '100 allow http and https access':
      port   => [80, 443],
      proto  => tcp,
      action => accept,
    }
  }

  if $repo_provider == 'git' {
    ensure_packages(['git'])

    Vcsrepo {
      require => Package['git'],
    }
  }

  $website_hash.each do |String $site_name, Hash $website| {
    $_docroot = "/var/www/${website['docroot']}"

    apache::vhost { $site_name:
      docroot        => $_docroot,
      manage_docroot => $website['manage_docroot'],
      port           => $website['port'],
      priority       => $website['priority'],
    }

    if $website['repo_source'] {
      vcsrepo { $site_name:
        ensure   => present,
        path     => $_docroot,
        provider => $website['repo_provider'],
        source   => $website['repo_source'],
        require  => Apache::Vhost[$site_name],
      }
    } elsif $website['site_package'] {
      package { $website['site_package']:
        ensure => present,
        tag    => 'custom',
      }
    }
  }

}
