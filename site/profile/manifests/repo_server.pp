class profile::repo_server (
  Hash $repo_data,
  Hash $repo_defaults,
) {

  include ::apache
  include ::apache::mod::php
  include ::apache::mod::authn_file
  $repo_data.each |String $repo_name, Hash $repo_hash| {
    @@yumrepo { $repo_name:
      * => $repo_hash;
      default:
        * => $repo_defaults;
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
