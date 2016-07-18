# == Class: profile::ssh
#
# Class to call other profile to manage all the ssh requirements
#
# === Variables
#
# All variables from Hiera with no defaults
#
# [*allowed_groups*]
#   List of groups allowed.
#
# [*banner_content*]
#   Content of banner file.
#
# [*enable_firewall*]
#   Boolean to determine if firewall settings are required.
#
# [*options_hash*]
#   Hash of options for sshd_config.
#
# === Authors
#
# Brett Gray <brett.gray@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs, unless otherwise noted.
#
class profile::ssh {

  $allowed_groups   = hiera_array('profile::ssh::allowed_groups')
  $banner_content   = hiera('profile::ssh::banner_content')
  $enable_firewall  = hiera('profile::ssh::enable_firewall')
  $options_hash     = hiera_hash('profile::ssh::options_hash')
  $noop_scope       = hiera('profile::ssh::noop_scope', false)

  if $::brownfields and $noop_scope {
    noop()
  }

  validate_bool($enable_firewall)

  if $enable_firewall {
    # include firewall rule
    firewall { '100 allow ssh access':
      dport  => '22',
      proto  => 'tcp',
      action => 'accept',
    }
  }

  @@nagios_service { "${::fqdn}_ssh":
    ensure              => present,
    use                 => 'generic-service',
    host_name           => $::fqdn,
    service_description => "SSH",
    check_command       => 'check_ssh',
    target              => "/etc/nagios/conf.d/${::fqdn}_service.cfg",
    notify              => Service['nagios'],
    require             => File["/etc/nagios/conf.d/${::fqdn}_service.cfg"],
  }

  file { ['/etc/issue','/etc/issue.net']:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $banner_content,
  }

  $ssh_group_hash = {'AllowGroups' => join($allowed_groups, ' ')}

  class { '::ssh::server':
    storeconfigs_enabled => false,
    options              => merge($options_hash, $ssh_group_hash),
  }

}
