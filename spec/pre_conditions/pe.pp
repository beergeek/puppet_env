service { 'mcollective':
  ensure => running,
  enable => true,
}

service { 'pe-puppetserver':
    ensure => 'running',
}
