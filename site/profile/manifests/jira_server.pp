class profile::jira_server (
  Hash $firewall_rule_defaults,
  String $jira_app_dir,
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

  java_ks { 'jira_ks':
    ensure       => latest,
    certificate  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    target       => "${jira_app_dir}/jira.jks",
    password     => 'changeit',
    trustcacerts => true,
  }

}
