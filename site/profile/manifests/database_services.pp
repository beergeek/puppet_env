class profile::database_services {

  case $facts['kernel'] {
    'linux': {
      include profile::database_services::mysql
    }
    'windows': {
      include profile::database_services::sqlserver
    }
    default: {
      fail("${facts['kernel']} is not a support OS kernel")
    }
  }
}
