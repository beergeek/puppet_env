class profile::web_services {

  case $::kernel {
    'linux': {
      include profile::web_services::apache
    }
    'windows': {
      include profile::web_services::iis
    }
    default: {
      fail("${::kernel} is not a support OS kernel")
    }
  }
}
