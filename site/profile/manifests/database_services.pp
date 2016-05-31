class profile::database_services {

  case $::kernel {
    'linux': {
      include profile::database_services::mysql
    }
    'windows': {
      include profile::database_services::sqlserver
    }
    default: {
      fail("${::kernel} is not a support OS kernel")
    }
  }
}
