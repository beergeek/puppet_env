#
class role::pfa_server {
  require profile::base
  include profile::pipelines
}
