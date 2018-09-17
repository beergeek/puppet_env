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

  # let's try something else
  Host <<| |>>
  #$env_hosts = puppetdb_query( "resources[title, parameters] {type = \"Host\" and exported = true and environment = \"${server_facts['environment']}\" and !(certname = \"${trusted['certname']}\")}")
#
  #if $env_hosts and ! empty($env_hosts) {
  #  $env_hosts.each |Hash $host_data| {
  #    host { $host_data['title']:
  #      * => $host_data['parameters'],
  #    }
  #  }
  #}

  if $purge {
    resources { 'host':
      purge => true,
    }
  }
}
