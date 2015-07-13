class profiles::mysql_php {

  include ::mysql::server
  class {'::mysql::bindings':
    php_enable => true,
  }

  user {'brett':
    ensure => present,
    tag    => ['admin','cdrom'],
  }
}
