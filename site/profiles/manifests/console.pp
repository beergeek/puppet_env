class profiles::console (
  $ssl_dir          = $::settings::ssldir,
  $common_certname  = undef,
) {

  validate_absolute_path($ssl_dir)

  File {
    ensure => file,
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    mode   => '0644',
  }

  #if we have a common cert let's use it
  if $common_certname {
    class { 'pe_ha::console::common':
      common_certname => $common_certname,
    }
  }

  # These file resources copy the dashboard certs from the active master
  # to the passive master using the file() function.
  # This means that these certs are only going to be up-to-date
  # when Puppet runs (so, every 30 minutes by default).
  #
  file { "${ssl_dir}/certs/pe-internal-dashboard.pem":
    content => file("${ssl_dir}/certs/pe-internal-dashboard.pem"),
  }

  file { "${ssl_dir}/public_keys/pe-internal-dashboard.pem":
    content => file("${ssl_dir}/public_keys/pe-internal-dashboard.pem"),
  }

  file { "${ssl_dir}/private_keys/pe-internal-dashboard.pem":
    mode    => '0400',
    content => file("${ssl_dir}/private_keys/pe-internal-dashboard.pem"),
  }

  file { "${ssl_dir}/certs/pe-internal-classifier.pem":
    content => file("${ssl_dir}/certs/pe-internal-classifier.pem"),
  }

  file { "${ssl_dir}/public_keys/pe-internal-classifier.pem":
    content => file("${ssl_dir}/public_keys/pe-internal-classifier.pem"),
  }

  file { "${ssl_dir}/private_keys/pe-internal-classifier.pem":
    mode    => '0400',
    content => file("${ssl_dir}/private_keys/pe-internal-classifier.pem"),
  }

}
