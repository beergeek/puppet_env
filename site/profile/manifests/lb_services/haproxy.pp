class profile::lb_services::haproxy {

  $listeners        = hiera('profile::lb_services::haproxy::listeners',undef)
  $enable_firewall  = hiera('profile::lb_services::haproxy::enable_firewall')
  $frontends        = hiera('profile::lb_services::haproxy::frontends',undef)
  $backends         = hiera('profile::lb_services::haproxy::backends',undef)

  Firewall {
    before  => Class['profile::fw::post'],
    require => Class['profile::fw::pre'],
  }

  include ::haproxy

  if $listeners {
    $listeners.each |String $listener,Hash $listener_values| {
      haproxy::listen { $listener:
        collect_exported => $listener_values['collect_exported'],
        ipaddress        => pick($::os['interfaces']['eth1'],$::os['interfaces']['enp0s8'],$::os['interfaces']['eth0'],$::os['interfaces']['enp0s3']),
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
        * => $frontend_values,;
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
