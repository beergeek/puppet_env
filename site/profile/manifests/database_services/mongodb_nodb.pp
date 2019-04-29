#
class profile::database_services::mongodb_nodb (
  Boolean          $enable_firewall = true,
  Array[String[1]] $firewall_ports  = ['27017'],
) {
  require mongodb::os
  require mongodb::user

  if $enable_firewall {
    $firewall_ports.each |String $_port| {
    # firewall rules
    firewall { "101 allow mongodb ${_port} access":
      dport  => [$_port],
      proto  => tcp,
      action => accept,
    }
  }

  include mongodb::automation_agent::install
  include mongodb::automation_agent::config
  include mongodb::automation_agent::service

  Class['mongodb::automation_agent::install'] ->
  Class['mongodb::automation_agent::config'] ->
  Class['mongodb::automation_agent::service']
}
