class profile::database_services (
  Enum['mysql','postgresql'] $linux_db = 'mysql',
) {

  case $facts['kernel'] {
    'linux': {
      if $linux_db == 'mysql' {
        include profile::database_services::mysql
      } elsif $linux_db == 'postgresql' {
        include profile::database_services::postgresql
      } else {
        fail("No database selected")
      }
    }
    'windows': {
      include profile::database_services::sqlserver
    }
    default: {
      fail("${facts['kernel']} is not a support OS kernel")
    }
  }
}
