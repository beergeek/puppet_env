class profiles::ntp_client {

  $ntp_servers = hiera('profiles::ntp_client::ntp_servers')
  validate_array($ntp_servers)

  if $::osfamily != 'windows' {
    class {'ntp':
      servers => $ntp_servers,
    }
  } else {
    class {'winntp':
      ntp_server => $ntp_servers,
    }
  }
}
