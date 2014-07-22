node /^web{\d+3}.puppetlabs.vm$/ {
  include role::webserver
}

node /^db{\d+3}.puppetlabs.vm$/ {
  include role::dbserver
}

node default {

  include profiles::base

}
