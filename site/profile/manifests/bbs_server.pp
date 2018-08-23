class profile::bbs_server (
  Stdlib::Absolutepath        $bbs_data_dir     = '/var/atlassian/application-data/bbs',
  Array[Stdlib::Absolutepath] $bbs_base_dirs    = ['/opt/atlassian','/var/atlassian','/var/atlassian/application-data'],
  String                      $bbs_user         = 'atlbitbucket',
  String                      $bbs_grp          = 'atlbitbucket',
  Boolean                     $enable_firewall  = true,
  Optional[Hash]              $firewall_rules   = {},

  # Noop
  Boolean                     $noop_scope       = false,
) {

  if $noop_scope {
    noop(true)
  }

  file { $bbs_base_dirs:
    ensure => directory,
    owner  => $bbs_user,
    group  => $bbs_grp,
    mode   => '0755',
  }

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

  file { "${bbs_data_dir}/bbs.jks":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  java_ks { 'bbs_ks':
    ensure       => latest,
    certificate  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    target       => "${bamboo_data_dir}/bbs.jks",
    password     => 'changeit',
    trustcacerts => true,
    require      => [Java::Oracle['jdk8'],File["${bbs_data_dir}/bbs.jks"]],
  }
}
