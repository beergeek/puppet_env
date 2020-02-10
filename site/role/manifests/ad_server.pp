#
class role::ad_server {
  require profile::base
  include profile::ad_services
}
