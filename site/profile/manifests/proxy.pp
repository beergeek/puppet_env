class profile::proxy {

  if $facts['kernel'] == 'Linux' {
    include profile::proxy::squid
  }
}
