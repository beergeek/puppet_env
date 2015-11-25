class profiles::monitor_server {

  if $::osfamily != 'redhat' {
    fail("This class is only for EL family")
  }

  require epel
  include apache
  ensure_packages('nagios')

  file { '/etc/httpd/conf.d':
    ensure  => directory,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '0755',
    require => Package['nagios'],
  }

  file { '/etc/httpd/conf.d/nagios.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('profiles/nagios.conf.erb'),
    require => Package['nagios'],
  }

  service { 'nagios':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/httpd/conf.d/nagios.conf'],
  }

  Nagios_host <<||>>
  Nagios_service <<||>>

}
