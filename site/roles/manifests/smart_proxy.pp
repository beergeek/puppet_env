class roles::smart_proxy {

  include profiles::base
  profiles::f5_proxy {'f5.puppetlabs.lan': }

}
