#
class role::mongodb_server {
  require profile::base
  require profile::ldap
  include profile::database_services::mongodb
}
