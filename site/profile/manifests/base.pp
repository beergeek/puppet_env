class profile::base (
  Hash $sysctl_settings,
  Hash $sysctl_defaults,
  String $wsus_server,
  String $wsus_server_port,
  Boolean $noop_scope               => false,
  Boolean $enable_firewall          => true,
  Optional[Hash] $mco_client_array  => undef,
) {

  if $::brownfields and $noop_scope {
    noop(true)
  } else {
    noop(false)
  }

  case $::kernel {
    'linux': {

      Firewall {
        before  => Class['profile::fw::post'],
        require => Class['profile::fw::pre'],
      }

      if $enable_firewall {
        include ::firewall
        include profile::fw::pre
        include profile::fw::post
      } else {
        class { '::firewall':
          ensure => stopped,
        }
      }

      contain epel
      include make_noop

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
        mode   => '0777',
      }

      # repo management
      include profile::repos

      # monitoring
      include profile::monitoring

      # manage time, timezones, and locale
      include profile::time_locale

      # manage SSH
      include profile::ssh

      # manage SUDO
      include profile::sudo

      # manage logging
      #include profile::logging

      # manage DNS stuff
      include profile::dns

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

      include chocolatey
      Class['chocolatey'] -> Package<||>

      reboot { 'after_dotnet':
        apply => 'immediately',
        when  => pending,
      }

      reboot { 'after_powershell':
        apply => 'immediately',
        when  => pending,
      }

      package { 'dotnet4.5.2':
        ensure          => present,
        provider        => 'chocolatey',
        notify          => Reboot['after_dotnet'],
      }

      package { 'powershell':
        ensure          => present,
        provider        => 'chocolatey',
        install_options => ['-pre'],
        notify          => Reboot['after_powershell'],
      }

      # monitoring
      include profile::monitoring

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
