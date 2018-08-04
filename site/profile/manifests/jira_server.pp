class profile::jira_server (
  # Jira
  Profile::Pathurl            $source_location        = 'https://product-downloads.atlassian.com/software/jira/downloads',
  Boolean                     $manage_jira_grp        = true,
  Boolean                     $manage_jira_user       = true,
  Stdlib::Absolutepath        $jira_data_dir          = '/var/atlassian/application-data/jira',
  Stdlib::Absolutepath        $jira_install_dir       = '/opt/atlassian/jira',
  String                      $jira_grp               = 'jira',
  String                      $jira_user              = 'jira',
  String                      $jira_version           = '7.11.0',
  Array[Stdlib::Absolutepath] $jira_base_dirs         = ['/opt/atlassian','/var/atlassian','/var/atlassian/application-data'],

  # Firewall
  Boolean                     $enable_firewall        = true,
  Hash                        $firewall_rule_defaults = {ensure => present, proto => 'tcp', action => 'accept'},
  Optional[Hash]              $firewall_rules         = {},

  # Database
  Boolean                     $manage_db_settings     = true,
  Profile::Db_type            $db_type                = 'postgresql',
  Optional[Stdlib::Fqdn]      $db_host                = 'localhost',
  Optional[String]            $db_name                = 'jiradb',
  Optional[String]            $db_password            = undef,
  Optional[String]            $db_port                = undef,
  Optional[String]            $db_user                = 'jira',

  # Noop
  Boolean                     $noop_scope               = false,
) {

  if $noop_scope {
    noop(true)
  }

  file { $jira_base_dirs:
    ensure => directory,
    owner  => $jira_user,
    group  => $jira_grp,
    mode   => '0755',
  }

  if $manage_db_settings {
    if $db_type == 'postgresql' {
      require profile::database_services::postgresql

      postgresql::server::db { $db_name:
        user     => $db_user,
        password => $db_password,
        locale   => 'en_AU',
        encoding => 'UTF8',
        grant    => ['ALL'],
      }
    } elsif $db_type == 'mysql' {
      require profile::database_services::mysql

      mysql::db { $db_name:
        ensure   => present,
        user     => $db_user,
        password => $db_password,
        charset  => 'utf8',
        collate  => 'utf8_bin',
        grant    => ['ALL'],
      }
    }
  }

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

  file { "${jira_data_dir}/jira.jks":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  java_ks { 'jira_ks':
    ensure       => latest,
    certificate  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    target       => "${jira_app_dir}/jira.jks",
    password     => 'changeit',
    trustcacerts => true,
    require      => [Java::Oracle['jdk8'],File["${jira_data_dir}/jira.jks"]],
  }

}
