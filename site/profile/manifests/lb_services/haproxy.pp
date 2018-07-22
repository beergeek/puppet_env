class profile::lb_services::haproxy (
  Optional[Hash] $listeners = undef,
  Boolean $enable_firewall  = true,
  Optional[Hash] $frontends = undef,
  Optional[Hash] $backends  = undef,
) {

  Firewall {
    before  => Class['profile::fw::post'],
    require => Class['profile::fw::pre'],
  }

  include ::haproxy

  if $listeners {
    $listeners.each |String $listener,Hash $listener_values| {
      haproxy::listen { $listener:
        ipaddress => $facts['networking']['ip'],
        *         => $listener_values
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
