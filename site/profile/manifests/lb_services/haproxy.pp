class profile::lb_services::haproxy (
  Optional[Hash] $listeners = undef,
  Boolean $enable_firewall  = true,
  Optional[Hash] $frontends = undef,
  Optional[Hash] $backends  = undef,
  Optional[Boolean] $noop_scope,
) {

  if $noop_scope {
    noop(true)
  }

  Firewall {
    before  => Class['profile::fw::post'],
    require => Class['profile::fw::pre'],
  }

  include ::haproxy

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

  if $listeners {
    $listeners.each |String $listener,Hash $listener_values| {
      haproxy::listen { $listener:
        collect_exported => $listener_values['collect_exported'],
        ipaddress        => $ip,
        ports            => $listener_values['ports'],
        options          => $listener_values['options'],
      }

      if $enable_firewall {
        firewall { "100 ${listener}":
          dport  => [$listener_values['ports']],
          proto  => 'tcp',
          action => 'accept',
        }
      }
    }
  }

  if $frontends {
    $frontends.each |String $frontend, Hash $frontend_values| {
      haproxy::frontend { $frontend:
        * => $frontend_values,
      }

      if $enable_firewall {
        firewall { "100 ${frontend}":
          dport  => [$frontend_values['ports']],
          proto  => 'tcp',
          action => 'accept',
        }
      }
    }
  }

  if $backends {
    $backends.each |String $backend, Hash $backend_values| {
      haproxy::backend { $backend:
        * => $backend_values,
      }
    }
  }
}
