#
class role::mongodb_nodb_server {
  require profile::base
  include profile::database_services::mongodb_nodb
}
