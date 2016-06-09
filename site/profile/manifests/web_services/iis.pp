class profile::web_services::iis {

  $website_hash 	    = hiera('profile::web_services::ii::website_hash')

  include ::iis

  # disable default website
  iis::manage_site { 'Default Web Site':
    ensure    => absent,
    site_path => 'C:\inetpub\wwwroot',
    app_pool  => 'Default Web Site',
  }

  iis::manage_app_pool { 'Default Web Site':
    ensure => absent,
  }

  website_hash.each do |String $site_name, Hash website| {
    $_docroot = "C:\\inetpub\\wwwroot\\${website['docroot']}"

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
      source  => "puppet:///web_sites/${site_name}",
    }
  }
}
