Package {
  allow_virtual => false,
}

node /^vcac-sdl-web-\d{4}/ {
  include roles::frontend_webserver
}

node /^vcac-sdl-db-\d{4}/ {
  include roles::backend_dbserver
}

node default {
  @@host { $::fqdn:
    ensure        => present,
    host_aliases  => [$::hostname],
    ip            => $::ipaddress,
  }

}
