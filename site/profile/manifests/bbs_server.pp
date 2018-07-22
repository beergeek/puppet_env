class profile::bbs_server (
  Hash $firewall_rule_defaults,
  String $bbs_app_dir,
  Boolean $enable_firewall        = true,
  Optional[Hash] $firewall_rules  = {},
) {

  include profile::database_services

  if $enable_firewall {
    if $firewall_rules {
      $firewall_rules.each |String $rule_name, Hash $rule_data| {
        firewall { $rule_name:
          *   => $rule_data;
          default:
            * => $firewall_rule_defaults,
        }
      }
    }
  }

  java::oracle { 'jdk8' :
    ensure  => 'present',
    version => '8',
    java_se => 'jdk',
  }

  java_ks { 'bbs_ks':
    ensure       => latest,
    certificate  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    target       => "${bbs_app_dir}/bbs.jks",
    password     => 'changeit',
    trustcacerts => true,
  }

}
