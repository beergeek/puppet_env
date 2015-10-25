# == Class: profiles::sudo
#
# Class to call other profiles to manage all the sudo requirements
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
class profiles::sudo {

  $sudo_hash            = hiera_hash('profiles::sudo::sudo_hash')
  $sudo_hash_defaults   = hiera('profiles::sudo::sudo_hash_defaults')
  $sudo_purge           = hiera('profiles::sudo::sudo_purge')
  $sudo_replace_config  = hiera('profiles::sudo::sudo_replace_config')

  class { '::sudo':
    purge               => $sudo_purge,
    config_file_replace => $sudo_replace_config,
  }

  create_resources('sudo::conf', $sudo_hash, $sudo_hash_defaults)
}
