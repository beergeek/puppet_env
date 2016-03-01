define profile::f5_proxy (
  $f5_device = $name,
) {

  f5_v11::config {"${f5_device}":
    username => 'admin',
    password => 'admin',
    url      => $f5_device,
    target   => "/etc/puppetlabs/puppet/${f5_device}.conf",
  }

	File {
	  owner => 'pe-puppet',
	  group => 'pe-puppet',
	}

	file {"/var/opt/lib/pe-puppet/devices":
	  ensure => directory,
	  mode   => '0750'
	}

	file {"/var/opt/lib/pe-puppet/devices/${f5_device}":
	  ensure => directory,
	  mode   => '0755',
	}

	file {"/var/opt/lib/pe-puppet/devices/${f5_device}/ssl":
	  ensure => directory,
	  owner  => '0771',
	}

	file {"/var/opt/lib/pe-puppet/devices/${f5_device}/ssl/private_keys":
	  ensure => directory,
	  owner  => '0771',
	}

	file {"/var/opt/lib/pe-puppet/devices/${f5_device}/ssl/certs":
	  ensure => directory,
	  owner  => '0771',
	}

	file {"/var/opt/lib/pe-puppet/devices/${f5_device}/ssl/private_keys/${f5_device}.pem":
	  ensure  => file,
	  mode    => '0600',
	  content => file("/etc/puppetlabs/puppet/ssl/private_keys/${f5_device}.pem"),
	}

	file {"/var/opt/lib/pe-puppet/devices/${f5_device}/ssl/certs/ca.pem":
	  ensure  => file,
	  mode    => '0644',
	  content => file('/etc/puppetlabs/puppet/ssl/certs/ca.pem'),
	}

	file {"/var/opt/lib/pe-puppet/devices/${f5_device}/ssl/certs/${f5_device}.pem":
	  ensure  => file,
	  mode    => '0644',
	  content => file("/etc/puppetlabs/puppet/ssl/certs/${f5_device}.pem"),
	}

	file {"/var/opt/lib/pe-puppet/devices/${f5_device}/ssl/crl.pem":
	  ensure  => file,
	  content => file('/etc/puppetlabs/puppet/ssl/crl.pem'),
	}
}

