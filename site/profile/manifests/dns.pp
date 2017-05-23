class profile::dns (
  Optional[Array] $name_servers = undef,
  Boolean $purge                = false,
  Boolean $noop_scope           = false,
) {

  if $facts['brownfields'] and $noop_scope {
    noop(true)
  } else {
    noop(false)
  }

  case $facts['kernel'] {
    'Linux': {
      if has_key($facts['networking']['interfaces'],'enp0s8') {
        $ip = $facts['networking']['interfaces']['enp0s8']['ip']
      } elsif has_key($facts['networking']['interfaces'],'eth1') {
        $ip = $facts['networking']['interfaces']['eth1']['ip']
      } elsif has_key($facts['networking']['interfaces'],'enp0s3') {
        $ip = $facts['networking']['interfaces']['enp0s3']['ip']
      } elsif has_key($facts['networking']['interfaces'],'eth0') {
        $ip = $facts['networking']['interfaces']['eth0']['ip']
      } else {
        fail("Buggered if I know your IP Address")
      }

      if $name_servers {
        class { '::resolv_conf':
          domainname  => $facts['domain'],
          nameservers => $name_servers,
        }
      }
    }
    'windows': {
      $ip = $facts['networking']['ip']
    }
    default: {
      fail("You need an operating system")
    }
  }

  @@host { $facts['fqdn']:
    ensure        => present,
    host_aliases  => [$facts['hostname']],
    ip            => $ip,
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
