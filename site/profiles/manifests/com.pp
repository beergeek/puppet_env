class profiles::com {

  $manage_r10k    = hiera('profiles::com::manage_r10k', true)
  $r10K_sources   = hiera_hash('profiles::com::r10K_sources', undef)
  $manage_hiera   = hiera('profiles::com::manage_hiera', true)
  $hiera_backends = hiera_hash('profiles::com::hiera_backends',{'yaml' =>  {'data' =>'/etc/puppetlabs/puppet/environment/%{environments/hieradata'}})
  $hiera_hierarchy = hiera_array('profiles::com::hiera_hierarchy', ['%{clientcert}','%{tier}','%{data_centre}','global'])

  if $manage_r10k and ! $r10K_sources {
    fail('The hash `r10k_sources` must exist when managing r10k')
  }

  @@haproxy::balancermember { "master00-${::fqdn}":
    listening_service => 'puppet00',
    server_names      => $::fqdn,
    ipaddresses       => $::ipaddress_eth1,
    ports             => '8140',
    options           => 'check',
  }

  if $manage_r10k {
    class { '::r10k':
      sources => $r10K_sources,
      notify  => Exec['r10k_sync'],
    }

    exec { 'r10k_sync':
      command     => '/opt/puppet/bin/r10k deploy environment -p',
      refreshonly => true,
    }
  }

  if $manage_hiera {
    file { '/etc/puppetlabs/puppet/hiera.yaml':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('profiles/hiera.yaml.erb'),
      notify  => Service['pe-puppetserver'],
    }
  }

}
