class profile::base {

  $noop_scope = hiera('profile::base::noop_scope', false)

  if $::brownfields and $noop_scope {
    noop()
  }

  case $::kernel {
    'linux': {
      $sysctl_settings  = hiera('profile::base::sysctl_settings')
      $sysctl_defaults  = hiera('profile::base::sysctl_defaults')
      $mco_client_array = hiera_array('profile::base::mco_client_array', undef)
      $enable_firewall  = hiera('profile::base::enable_firewall',true)

      Firewall {
        before  => Class['profile::fw::post'],
        require => Class['profile::fw::pre'],
      }

      if $enable_firewall {
        class { 'firewall':
        }
        class {['profile::fw::pre','profile::fw::post']:
        }
      } else {
        class { 'firewall':
          ensure => stopped,
        }
      }

      contain epel

      # old way
      # create_resources(sysctl,$sysctl_settings, $sysctl_defaults)
      # new way
      $sysctl_settings.each |String $sysctl_name, Hash $sysctl_hash| {
        sysctl { $sysctl_name:
          * => $sysctl_hash,;
          default:
            * => $sysctl_defaults,;
        }
      }

      ensure_packages(['ruby'])
      file { ['/etc/puppetlabs/facter','/etc/puppetlabs/facter/facts.d']:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      # repo management
      class { 'profile::repos': }

      # monitoring
      class { 'profile::monitoring': }

      # manage time, timezones, and locale
      class { 'profile::time_locale': }

      # manage SSH
      class { 'profile::ssh': }

      # manage SUDO
      class { 'profile::sudo': }

      # manage logging
      #class { 'profile::logging': }

      # manage DNS stuff
      class { 'profile::dns': }

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

      exec { 'update mco facts':
        command => '/opt/puppetlabs/puppet/bin/refresh-mcollective-metadata >>/var/log/puppetlabs/mcollective-metadata-cron.log 2>&1',
        unless  => '/usr/bin/test -e /etc/puppetlabs/mcollective/facts.yaml',
      }
    }
    'windows': {

      $wsus_server      = hiera('profile::base::wsus_server')
      $wsus_server_port = hiera('profile::base::wsus_server_port')

      # monitoring
      class { 'profile::monitoring': }

      file { ['C:/ProgramData/PuppetLabs/facter','C:/ProgramData/PuppetLabs/facter/facts.d']:
        ensure => directory,
      }

      acl { ['C:/ProgramData/PuppetLabs/facter','C:/ProgramData/PuppetLabs/facter/facts.d']:
        purge                      => false,
        permissions                => [
         { identity => 'vagrant', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all' },
         { identity => 'Administrators', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all'}
        ],
        owner                      => 'vagrant',
        group                      => 'Administrators',
        inherit_parent_permissions => true,
      }

      # setup wsus client
      class { 'wsus_client':
        server_url => "${wsus_server}:${wsus_server_port}",
      }
    }
  }

}
