# == Class: profile::sudo
#
# Class to call other profile to manage all the sudo requirements
#
# === Variables
#
# All variables from Hiera with no defaults
#
# [*sudo_hash*]
#   Netsted hash of details for sudo.
#
# [*sudo_hash_defaults*]
#   Hash of defaults for sudo.
#
# [*sudo_purge*]
#   Boolean to determine if other sudo entries not under Puppet control are purged.
#
# [*sudo_replace_config*]
#   Boolean to determine if the sudo config is replaced.
#
# === Authors
#
# Brett Gray <brett.gray@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs, unless otherwise noted.
#
class profile::sudo {

  $sudo_hash            = hiera_hash('profile::sudo::sudo_hash')
  $sudo_hash_defaults   = hiera('profile::sudo::sudo_hash_defaults')
  $sudo_purge           = hiera('profile::sudo::sudo_purge')
  $sudo_replace_config  = hiera('profile::sudo::sudo_replace_config')
  $noop_scope           = hiera('profile::sudo::noop_scope', false)

  if $::brownfields and $noop_scope {
    noop()
  }

  class { '::sudo':
    purge               => $sudo_purge,
    config_file_replace => $sudo_replace_config,
  }

  # old school
  # create_resources('sudo::conf', $sudo_hash, $sudo_hash_defaults)
  # new school
  $sudo_hash.each |String $sudo_name,Hash $sudo_hash_value| {
    sudo::conf { $sudo_name:
      * => $sudo_hash_value,;
      default:
        * => $sudo_hash_defaults,;
    }
  }
}
