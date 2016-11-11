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

  if has_key($::networking['interfaces'], 'eth1') {
    $check_port = $networking['interfaces']['eth1']['bindings'][0]['address']
  } elsif has_key($::networking['interfaces'], 'eth0') {
    $check_port = $networking['interfaces']['eth0']['bindings'][0]['address']
  } elsif has_key($::networking['interfaces'], 'enp0s8') {
    $check_port = $networking['interfaces']['enp0s8']['bindings'][0]['ip']
  } elsif has_key($::networking['interfaces'], 'enp0s3') {
    $check_port = $networking['interfaces']['enp0s3']['bindings'][0]['ip']
  } else {
    fail('No IP found')
  }

  if $listeners {
    $listeners.each |String $listener,Hash $listener_values| {
      haproxy::listen { $listener:
        collect_exported => $listener_values['collect_exported'],
        ipaddress        => $check_port, 
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
