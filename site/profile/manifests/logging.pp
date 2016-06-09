# == Class: profile::logging
#
# Class to call other profile to manage all the logging requirements
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
class profile::logging {

  $log_local      = hiera('profile::logging::log_local')
  $port           = hiera('profile::logging::port')
  $remote_servers = hiera('profile::logging::remote_servers')
  $remote_type    = hiera('profile::logging::remote_type')
  $rotate         = hiera('profile::logging::rotate')
  $rotate_every   = hiera('profile::logging::rotate_every')
  $size           = hiera('profile::logging::size')
  $noop_scope     = hiera('profile::logging::noop_scope', false)

  if $::brownfields and $noop_scope {
    noop()
  }

  class { '::rsyslog::client':
    remote_servers => $remote_servers,
    remote_type    => $remote_type,
    port           => $port,
    log_local      => $log_local,
  }

  ::logrotate::rule { 'all_log':
    path         => '/var/log/*/*',
    rotate       => 0 + $rotate,
    rotate_every => $rotate_every,
    size         => $size,
    compress     => true,
    postrotate   => '/usr/bin/killall -HUP rsyslog',
  }
}
