class profile::repo_server {

  $repo_data      = hiera_hash('profile::repo_server::repo_data')
  $repo_defaults  = hiera('profile::repo_server::repo_defaults')

  include profile::web_services

  $repo_data.each |String $repo_name, Hash $repo_hash| {
    @@yumrepo { $repo_name:
      * => $repo_hash,;
      default:
        * => $repo_defaults,;
    }
  }

  # The following is purely for this Vagrant env
  file { '/var/www/custom':
    ensure => link,
    target => '/vagrant/repo/custom',
  }

  file { '/var/www/repo':
    ensure => link,
    target => '/vagrant/repo/repo',
  }

}
