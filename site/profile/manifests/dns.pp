class profile::dns (
  Optional[Array] $name_servers = [],
  Boolean $purge                = false,
  Boolean $noop_scope           = false,
) {

  if $noop_scope {
    noop(true)
  }

  @@host { $facts['fqdn']:
    ensure       => present,
    host_aliases => [$facts['hostname']],
    ip           => $facts['ipaddress'],
  }

  host { 'localhost':
    ensure       => present,
    host_aliases => ['localhost.localdomai','localhost6','localhost6.localdomain6'],
    ip           => '127.0.0.1',
  }

  Host <<| |>>

  if $purge {
    resources { 'host':
      purge => true,
    }
  }
}
