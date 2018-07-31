class profile::cached (
  Boolean $use_cached_catalog = true,
) {

  if $use_cached_catalog {
    $ensure = 'present'
  } else {
    $ensure = 'absent'
  }

  case $facts['kernel'] {
    'windows': { $path = 'C:\ProgramData\PuppetLabs\puppet\puppet.conf' }
    'linux': { $path = '/etc/puppetlabs/puppet/puppet.conf' }
    default: { fail('You are not using an operating system!') }
  }

  pe_ini_setting { 'use_cached_catalog':
    ensure  => $ensure,
    path    => $path,
    section => 'agent',
    setting => 'use_cached_catalog',
    value   => true,
  }
}
