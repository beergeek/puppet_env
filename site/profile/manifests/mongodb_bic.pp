#
class profile::mongodb_bic (
  Boolean $enable_firewall,
  String  $firewall_port,
) {

  if $enable_firewall {
    # firewall rules
    firewall { "101 allow mongodb BIC access":
      dport  => [$firewall_port],
      proto  => tcp,
      action => accept,
    }
  }
}
