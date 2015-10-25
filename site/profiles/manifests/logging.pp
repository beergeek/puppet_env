# == Class: profiles::logging
#
# Class to call other profiles to manage all the logging requirements
#
#
# === Variables
#
# All variables from Hiera with no defaults
#
# [*log_local*]
#   Log level for rsyslog client.
#
# [*port*]
#   Port to communicate to Rsyslog server.
#
# [*remote_servers*]
#   Rsyslog server hostname.
#
# [*remote_type*]
#   Type of remote (tcp).
#
# [*rotate*]
#   How many rotates to keep.
#
# [*rotate_every*]
#   How often to rotate.
#
# [*size*]
#   Size of logs before rotate.
#
# === Authors
#
# Brett Gray <brett.gray@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs, unless otherwise noted.
#
class profiles::logging {

  $log_local      = hiera('profiles::logging::log_local')
  $port           = hiera('profiles::logging::port')
  $remote_servers = hiera('profiles::logging::remote_servers')
  $remote_type    = hiera('profiles::logging::remote_type')
  $rotate         = hiera('profiles::logging::rotate')
  $rotate_every   = hiera('profiles::logging::rotate_every')
  $size           = hiera('profiles::logging::size')

  class { '::rsyslog::client':
    remote_servers => $remote_servers,
    remote_type    => $remote_type,
    port           => $port,
    log_local      => $log_local,
  }

  ::logrotate::rule { 'all_log':
    path         => '/var/log/*/*',
    rotate       => $rotate,
    rotate_every => $rotate_every,
    size         => $size,
    compress     => true,
    postrotate   => '/usr/bin/killall -HUP rsyslog',
  }
}
