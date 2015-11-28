class profiles::puppet_users {

  $user_hash      = hiera_hash('profiles::puppet_users::user_hash')

  if $::kernel != 'Linux' {
    fail("This profile is only for Linux, not ${::kernel}")
  }

  $user_hash.each |$user_key, $user_values| {
    if $user_values['manage_user'] == true {
      user { $user_key:
        ensure     => present,
        managehome => true,
      }
    }

    file { "/home/${user_key}":
      ensure => directory,
      owner  => $user_key,
      group  => $user_key,
      mode   => '0700',
    }

    file { ["/home/${user_key}/.puppetlabs","/home/${user_key}/.puppetlabs/etc","/home/${user_key}/.puppetlabs/etc/puppet"]:
      ensure => directory,
      owner  => $user_key,
      group  => $user_key,
      mode   => '0755',
    }


    file { "/home/${user_key}/.puppetlabs/etc/puppet/puppet.conf":
      ensure => file,
      owner  => $user_key,
      group  => $user_key,
      mode   => '0644',
    }

    pe_ini_setting { "${user_key}_user":
      ensure  => present,
      path    => "/home/${user_key}/.puppetlabs/etc/puppet/puppet.conf",
      section => 'agent',
      setting => 'user',
      value   => $user_key,
    }

    pe_ini_setting { "${user_key}_server":
      ensure  => present,
      path    => "/home/${user_key}/.puppetlabs/etc/puppet/puppet.conf",
      section => 'agent',
      setting => 'server',
      value   => $::settings::server,
    }
  }
}
