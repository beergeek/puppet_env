class profiles::base {

  Firewall {
    before  => Class['profiles::fw::post'],
    require => Class['profiles::fw::pre'],
  }

  case $::kernel {
    'linux': {
      $sysctl_settings  = hiera('profiles::base::sysctl_settings')
      $sysctl_defaults  = hiera('profiles::base::sysctl_defaults')
      $mco_client_array = hiera_array('profiles::base::mco_client_array', undef)

      class { 'firewall': }
      class {['profiles::fw::pre','profiles::fw::post']:}

      create_resources(sysctl,$sysctl_settings, $sysctl_defaults)
      ensure_packages(['ruby'])
      file { ['/etc/puppetlabs/facter','/etc/puppetlabs/facter/facts.d']:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      # manage time, timezones, and locale
      class { 'profiles::time_locale': }

      # manage SSH
      class { 'profiles::ssh': }

      # manage SUDO
      class { 'profiles::sudo': }

      # manage logging
      #class { 'profiles::logging': }

      # manage DNS stuff
      class { 'profiles::dns': }

      if $mco_client_array {
        $mco_client_array.each |$cert_title| {
          file { $cert_title:
            ensure  => file,
            path    => "/etc/puppetlabs/mcollective/ssl/clients/${cert_title}-public.pem",
            owner   => 'root',
            group   => 'root',
            mode    => '0440',
            content => file("${::settings::ssldir}/public_keys/${cert_title}.pem",'/dev/null'),
            notify  => Service['mcollective'],
          }
        }
      }
    }
    'windows': {

      $wsus_server      = hiera('profiles::base::wsus_server')
      $wsus_server_port = hiera('profiles::base::wsus_server_port')

      file { ['C:/ProgramData/PuppetLabs/facter','C:/ProgramData/PuppetLabs/facter/facts.d']:
        ensure => directory,
      }

      acl { ['C:/ProgramData/PuppetLabs/facter','C:/ProgramData/PuppetLabs/facter/facts.d']:
        purge                      => false,
        permissions                => [
         { identity => 'Administrator', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all' },
         { identity => 'Administrators', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all'}
        ],
        owner                      => 'Administrators',
        group                      => 'Administrator',
        inherit_parent_permissions => true,
      }

      # setup wsus client
      class { 'wsus_client':
        server_url => "${wsus_server}:${wsus_server_port}",
      }
    }
  }

}
