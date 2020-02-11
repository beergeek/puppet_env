#
class role::mongodb_server {
  require profile::base
  include profile::database_services::mongodb
}
