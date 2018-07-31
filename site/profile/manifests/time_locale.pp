class profile::time_locale (
  Array $ntp_servers,
  String $timezone,
  String $locale_rhel,
  String $locale_deb,
  Array $lang_pack,
  Boolean $noop_scope = false,
) {

  if ($facts['brownfields']) and $noop_scope {
    noop(true)
  } else {
    unless $::settings::noop { noop(false) }
  }

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
    fail('This is for Linux only')
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
