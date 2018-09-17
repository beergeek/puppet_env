class profile::jira_server (
  # Jira
  Profile::Pathurl            $source_location        = 'https://product-downloads.atlassian.com/software/jira/downloads',
  Boolean                     $https                  = true,
  Boolean                     $manage_jira_grp        = true,
  Boolean                     $manage_jira_user       = true,
  Optional[String[1]]         $cacert                 = undef,
  Optional[String[1]]         $cert                   = undef,
  Optional[String[1]]         $private_key            = undef,
  Stdlib::Absolutepath        $java_home_default      = '/usr/java/jdk1.8.0_131/jre',
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
  Boolean                     $create_databases       = $manage_db_settings,
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

  if $https and ($cert == undef or $cacert == undef) {
    fail('Need CA Cert and Cert for HTTPS')
  }

  if $facts['java_default_home'] {
    $_java_home = $facts['java_default_home']
  } else {
    $_java_home = $java_home_default
  }

  file { $jira_base_dirs:
    ensure => directory,
    owner  => $jira_user,
    group  => $jira_grp,
    mode   => '0755',
  }

  if $create_databases {
    if $db_type == 'postgresql' {
      require profile::database_services::postgresql

      postgresql::server::db { $db_name:
        user     => $db_user,
        password => $db_password,
        locale   => 'en_AU',
        encoding => 'UTF8',
        grant    => ['ALL'],
        notify   => Class['jira'],
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
        notify   => Class['jira'],
      }
    }
  }

  class { 'jira':
    java_home          => $_java_home,
    jira_data_dir      => $jira_data_dir,
    jira_grp           => $jira_grp,
    jira_install_dir   => $jira_install_dir,
    jira_user          => $jira_user,
    https              => $https,
    db_host            => $db_host,
    db_name            => $db_name,
    db_password        => $db_password,
    db_port            => $db_port,
    db_type            => $db_type,
    db_user            => $db_user,
    manage_db_settings => $manage_db_settings,
    manage_grp         => $manage_jira_grp,
    manage_user        => $manage_jira_user,
    source_location    => $source_location,
    version            => $jira_version,
    require            => Java::Oracle['jdk8'],
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

  if $cacert {
    file { "${jira_data_dir}/cacert.pem":
      ensure  => file,
      content => $cacert,
      owner   => $jira_user,
      group   => $jira_grp,
      mode    => '0444',
    }
    java_ks { 'jira_ks_cacert':
      ensure       => present,
      certificate  => "${jira_data_dir}/cacert.pem",
      target       => "${jira_data_dir}/jira.jks",
      password     => 'changeit',
      trustcacerts => true,
      require      => [Java::Oracle['jdk8'],File["${jira_data_dir}/jira.jks"]],
      #notify       => Class['jira'],
    }
  }

  if $cert {
    file { "${jira_data_dir}/cert.pem":
      ensure  => file,
      content => $cert,
      owner   => $jira_user,
      group   => $jira_grp,
      mode    => '0444',
    }

    file { "${jira_data_dir}/key.pem":
      ensure  => file,
      content => $private_key,
      owner   => $jira_user,
      group   => $jira_grp,
      mode    => '0400',
    }

    java_ks { 'jira_ks_cert':
      ensure       => present,
      certificate  => "${jira_data_dir}/cert.pem",
      private_key  => "${jira_data_dir}/key.pem",
      target       => "${jira_data_dir}/jira.jks",
      password     => 'changeit',
      trustcacerts => true,
      require      => [Java::Oracle['jdk8'],File["${jira_data_dir}/jira.jks"]],
      #notify       => Class['jira'],
    }
  }
}
