class role::smart_proxy {

  include profile::base
  profile::f5_proxy {'f5.puppetlabs.lan': }

}
