class profile::base (
  Hash      $sysctl_settings,
  Hash      $sysctl_defaults,
  String    $wsus_server,
  String    $wsus_server_port,
  Boolean   $enable_firewall    = true,
) {

  case $facts['kernel'] {
    'linux': {

      if $enable_firewall {

        Firewall {
          before  => Class['profile::fw::post'],
          require => Class['profile::fw::pre'],
        }

        include ::firewall
        include profile::fw::pre
        include profile::fw::post
      } else {
        class { '::firewall':
          ensure => stopped,
        }
      }

      include epel

      #$sysctl_settings.each |String $sysctl_name, Hash $sysctl_hash| {
      #  sysctl { $sysctl_name:
      #    * => $sysctl_hash;
      #    default:
      #      * => $sysctl_defaults;
      #  }
      #}

      ensure_packages(['ruby'])
      file { ['/etc/puppetlabs/facter','/etc/puppetlabs/facter/facts.d']:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
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

    }
    'windows': {

      include profile::wsus_services
      include archive

      include chocolatey
      Class['chocolatey'] -> Package<||>

      reboot { 'dsc_reboot':
        message => 'DSC is rebooting this machine',
        when    => 'pending',
      }

      reboot { 'after_dotnet':
        apply => 'immediately',
        when  => pending,
      }

      reboot { 'after_powershell':
        apply => 'immediately',
        when  => pending,
      }

      package { 'dotnet4.5.2':
        ensure   => present,
        provider => 'chocolatey',
        notify   => Reboot['after_dotnet'],
      }

      package { 'powershell':
        ensure          => present,
        provider        => 'chocolatey',
        install_options => ['-pre'],
        notify          => Reboot['after_powershell'],
      }

      # monitoring
      include profile::monitoring

      file { 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate':
        ensure  => directory,
        recurse => true,
        source  => 'puppet:///dump/PSWindowsUpdate',
      }

      file { ['C:/ProgramData/PuppetLabs/facter','C:/ProgramData/PuppetLabs/facter/facts.d']:
        ensure => directory,
      }

      acl { ['C:/ProgramData/PuppetLabs/facter','C:/ProgramData/PuppetLabs/facter/facts.d']:
        purge                      => false,
        permissions                => [
          { identity => 'Administrators', rights => ['full'], perm_type=> 'allow', child_types => 'all', affects => 'all'}
        ],
        owner                      => 'Administrators',
        group                      => 'Administrators',
        inherit_parent_permissions => true,
      }

    }
  }

}
