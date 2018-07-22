class profile::com (
  Boolean              $enable_firewall       = true,
  Optional[Hash]       $firewall_rules        = {},
  Optional[String]     $hiera_eyaml_priv      = undef,
  Optional[String]     $hiera_eyaml_pub       = undef,
  Stdlib::Absolutepath $hiera_eyaml_priv_name = '/etc/puppetlabs/puppet/ssl/private_key.pkcs7.pem',
  Stdlib::Absolutepath $hiera_eyaml_pub_name  = '/etc/puppetlabs/puppet/ssl/public_key.pkcs7.pem',
) {

  if $enable_firewall {
    if $firewall_rules {
      $firewall_rules.each |String $rule_name, Hash $rule_data| {
        firewall { $rule_name:
          *   => $rule_data;
          default:
            proto  => 'tcp',
            action => 'accept',
        }
      }
    }
  }

  if $trusted['extensions']['pp_role'] != 'replica' {
    @@haproxy::balancermember { "master00-${facts['fqdn']}":
      listening_service => 'puppet00',
      server_names      => $facts['fqdn'],
      ipaddresses       => $facts['networking']['ip'],
      ports             => '8140',
      options           => 'check',
    }
    @@haproxy::balancermember { "pcp00-${facts['fqdn']}":
      listening_service => 'pcp00',
      server_names      => $facts['fqdn'],
      ipaddresses       => $facts['networking']['ip'],
      ports             => '8142',
      options           => 'check',
    }
  }

  if $hiera_eyaml_priv and $hiera_eyaml_pub {
    file { $hiera_eyaml_priv_name:
      ensure  => file,
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0600',
      content => $hiera_eyaml_priv,
      notify  => Service['pe-puppetserver'],
    }

    file { $hiera_eyaml_pub_name:
      ensure  => file,
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0600',
      content => $hiera_eyaml_pub,
      notify  => Service['pe-puppetserver'],
    }
  } elsif $hiera_eyaml_priv or $hiera_eyaml_pub {
    fail('Hiera-eyaml requires both the private and public keys')
  }

}
