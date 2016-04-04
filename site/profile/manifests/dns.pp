# == Class: profile::dns
#
# Class to manage all the dns requirements
#
#
# === Variables
#
# All variables from Hiera with no defaults
#
# [*name_servers*]
#   Array of name servers for /etc/resolv.conf.
#
# [*purge*]
#   Boolean value to determine if unmanaged host entries are purged.
#   Default: false
#
# === Authors
#
# Brett Gray <brett.gray@puppetlabs.com>
#
# === Copyright
#
# Copyright 2015 Puppet Labs, unless otherwise noted.
#
class profile::dns {

  $purge        = hiera('profile::dns::purge', false)
  $noop_scope = hiera('profile::base::noop_scope', false)

  if $::brownfields and $noop_scope {
    noop()
  }
  if $::kernel == 'Linux' {
    $name_servers = hiera('profile::dns::name_servers')

    validate_array($name_servers)
    validate_bool($purge)

    class { '::resolv_conf':
      domainname  => $::domain,
      nameservers => $name_servers,
    }
  }

  @@host { $::fqdn:
    ensure        => present,
    host_aliases  => [$::hostname],
    ip            => $::ipaddress_eth1,
  }

  host { 'localhost':
    ensure       => present,
    host_aliases => ['localhost.localdomai','localhost6','localhost6.localdomain6'],
    ip           => '127.0.0.1',
  }

  Host <<| |>>

  if $purge {
    resources { 'host':
      purge => true,
    }
  }
}
