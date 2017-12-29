class profile::monitor_server (
  Boolean $enable_firewall = true,
  Optional[Boolean] $noop_scope,
) {

  if $noop_scope {
    noop(true)
  }

  include apache::mod::authn_core
  include apache::mod::authn_file
  include apache::mod::auth_basic
  include apache::mod::authz_user

  if $facts['os']['family'] != 'redhat' {
    fail("This class is only for EL family")
  }

  package { ['nagios','nagios-plugins','nagios-plugins-all']:
    ensure  => present,
    require => Class['epel'],
  }

  file { '/etc/nagios/conf.d':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0755',
    require => Package['nagios'],
  }

  # apache config for nagios
  file { '/etc/httpd/conf.d/nagios.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('profile/nagios.conf.erb'),
    require => Package['nagios'],
  }

  service { 'nagios':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/httpd/conf.d/nagios.conf'],
  }

  File <<| tag == 'Monitoring' |>>
  Nagios_host <<||>>
  Nagios_service <<||>>

}
