#
class role::mongodb_nodb_server {
  require profile::base
  require profile::ldap
  include profile::database_services::mongodb_nodb
}
