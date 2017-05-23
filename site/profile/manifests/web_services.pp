class profile::web_services {

  case $facts['kernel'] {
    'linux': {
      include profile::web_services::apache
    }
    'windows': {
      include profile::web_services::iis
    }
    default: {
      fail("${facts['kernel']} is not a support OS kernel")
    }
  }
}
