class profile::bbs_server (
  Boolean                     $https                  = true,
  Boolean                     $manage_bbs_grp         = true,
  Boolean                     $manage_bbs_user        = true,
  Stdlib::Absolutepath        $bbs_data_dir           = '/var/atlassian/application-data/stash',
  Array[Stdlib::Absolutepath] $bbs_base_dirs          = ['/opt/atlassian','/var/atlassian','/var/atlassian/application-data'],
  String                      $bbs_user               = 'atlbitbucket',
  String                      $bbs_grp                = 'atlbitbucket',
  Optional[String[1]]         $cacert                 = undef,
  Optional[String[1]]         $cert                   = undef,
  Optional[String[1]]         $private_key            = undef,
  Stdlib::Absolutepath        $java_home_default      = '/usr/java/jdk1.8.0_131/jre',
  Boolean                     $enable_firewall        = true,
  Optional[Hash]              $firewall_rules         = {},

  # Noop
  Boolean                     $noop_scope       = false,
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
            ensure => present,
            proto  => 'tcp',
        }
      }
    }
  }

  class { 'bbs':
    java_home          => $_java_home,
    bbs_data_dir       => $bbs_data_dir,
    bbs_grp            => $bbs_grp,
    bbs_install_dir    => $bbs_install_dir,
    bbs_user           => $bbs_user,
    https              => $https,
    db_host            => $db_host,
    db_name            => $db_name,
    db_password        => $db_password,
    db_port            => $db_port,
    db_type            => $db_type,
    db_user            => $db_user,
    manage_db_settings => $manage_db_settings,
    manage_grp         => $manage_bbs_grp,
    manage_user        => $manage_bbs_user,
    source_location    => $source_location,
    version            => $jira_version,
    require            => Java::Oracle['jdk8'],
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

  if $cacert {
    file { "${bbs_data_dir}/cacert.pem":
      ensure  => file,
      content => $cacert,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
    }

    java_ks { 'bbs_ks_cacert':
      ensure       => present,
      certificate  => "${bbs_data_dir}/cacert.pem",
      target       => "${bbs_data_dir}/bbs.jks",
      password     => 'changeit',
      trustcacerts => true,
      require      => [Java::Oracle['jdk8'],File["${bbs_data_dir}/bbs.jks"]],
      #notify       => Class['bbs'],
    }
  }

  if $cert {
    file { "${bbs_data_dir}/cert.pem":
      ensure  => file,
      content => $cert,
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
    }
    file { "${bbs_data_dir}/key.pem":
      ensure  => file,
      content => $private_key,
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
    }

    java_ks { 'bbs_ks_cert':
      ensure       => present,
      certificate  => "${bbs_data_dir}/cert.pem",
      private_key  => "${bbs_data_dir}/key.pem",
      target       => "${bbs_data_dir}/bbs.jks",
      password     => 'changeit',
      trustcacerts => true,
      require      => [Java::Oracle['jdk8'],File["${bbs_data_dir}/bbs.jks"]],
      #notify       => Class['bbs'],
    }
  }
}
