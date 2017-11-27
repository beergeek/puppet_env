class profile::ssh (
  Boolean $enable_firewall  = true,
  Boolean $noop_scope       = false,
  Array[String] $allowed_groups,
  String $banner_content,
  Hash $options_hash,
) {

  if $facts['brownfields'] and $noop_scope {
    noop(true)
  } else {
    noop(false)
  }

  if $enable_firewall {
    # include firewall rule
    firewall { '100 allow ssh access':
      dport  => '22',
      proto  => 'tcp',
      action => 'accept',
    }
  }

  @@nagios_service { "${facts['fqdn']}_ssh":
    ensure              => present,
    use                 => 'generic-service',
    host_name           => $facts['fqdn'],
    service_description => "SSH",
    check_command       => 'check_ssh',
    target              => "/etc/nagios/conf.d/${facts['fqdn']}_service.cfg",
    notify              => Service['nagios'],
    require             => File["/etc/nagios/conf.d/${facts['fqdn']}_service.cfg"],
  }

  file { ['/etc/issue','/etc/issue.net']:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $banner_content,
  }

  $ssh_group_hash = {'AllowGroups' => join($allowed_groups, ' ')}

  class { '::ssh::server':
    storeconfigs_enabled => false,
    options              => merge($options_hash, $ssh_group_hash),
  }

}
