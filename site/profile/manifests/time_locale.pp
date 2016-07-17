# == Class: profile::time_locale
#
# Class to call other profile to manage all the locations requirements
#
# === Variables
#
# All variables from Hiera with no defaults
#
# [*ntp_servers*]
#   Array of ntp servers.
#
# [*timezone*]
#   Which time zone we want to be in.
#
# === Authors
#
# Brett Gray <brett.gray@puppetlabs.com>
#
# === Copyright
#
# Copyright 2014 Puppet Labs, unless otherwise noted.
#
class profile::time_locale {

  $ntp_servers  = hiera('profile::time_locale::ntp_servers')
  $timezone     = hiera('profile::time_locale::timezone')
  $locale_rhel  = hiera('profile::time_locale::locale_rhel')
  $locale_deb   = hiera('profile::time_locale::locale_deb')
  $lang_pack    = hiera('profile::time_locale::lang_pack')
  $noop_scope   = hiera('profile::time_locale::noop_scope', false)

  validate_bool($noop_scope)

  if (!$::fully_enabled) and $noop_scope {
    noop()
  }

  validate_array($ntp_servers)

  if $os['family'] == 'redhat' {
    file { '/etc/sysconfig/i18n':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    # manage the default locale
    file_line { 'locale':
      ensure => present,
      path   => '/etc/sysconfig/i18n',
      line   => "LANG=${locale_rhel}",
      match  => 'LANG=',
    }
  } elsif $os['family'] == 'debian' {
    package { $lang_pack: }

    class { 'locales':
      locales        => any2array($locale_deb),
      default_locale => $locale_deb,
      require        => Package[$lang_pack],
    }
  } else {
    fail("This is for Linux only")
  }

  # manage timezone
  class { '::timezone':
    timezone => $timezone,
  }

  # lets manage some NTP stuff
  class { '::ntp':
    servers => $ntp_servers,
  }
}
