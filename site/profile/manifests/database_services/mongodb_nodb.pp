#
class profile::database_services::mongodb_nodb (
  Boolean                $enable_firewall = true,
  Array[String[1]]       $firewall_ports  = ['27017'],
  Stdlib::Absolutepath   $base_data_path  = '/data',
  Stdlib::Absolutepath   $db_data_path    = '/data/db',
  Stdlib::Absolutepath   $db_log_path     = '/data/logs',
  String                 $mms_group_id,
  Sensitive[String[1]]   $mms_api_key,
  Stdlib::Fqdn           $ops_manager_fqdn,
  Enum['http','https']   $url_svc_type    = 'http', 
) {
  require mongodb::os
  require mongodb::user

  if $enable_firewall {
    $firewall_ports.each |String $_port| {
    # firewall rules
      firewall { "101 allow mongodb ${_port} access":
        dport  => [$_port],
        proto  => tcp,
        action => accept,
      }
    }
  }

  file { [$base_data_path, $db_data_path, $db_log_path]:
    ensure => directory,
    owner  => 'mongod',
    group  => 'mongod',
    mode   => '0750',
  }

  selinux::fcontext { "set-${db_data_path}-context":
    ensure   => present,
    seltype  => 'mongod_var_lib_t',
    seluser  => 'system_u',
    pathspec => "${db_data_path}.*",
    notify   => Exec["selinux-${db_data_path}"],
  }
  exec { "selinux-${db_data_path}":
    command     => "/sbin/restorecon -R -v ${db_data_path}",
    refreshonly => true,
  }
  selinux::fcontext { "set-${db_log_path}-context":
    ensure   => present,
    seltype  => 'mongod_log_t',
    seluser  => 'system_u',
    pathspec => "${db_log_path}.*",
    notify   => Exec["selinux-${db_log_path}"],
  }
  exec { "selinux-${db_log_path}":
    command     => "/sbin/restorecon -R -v ${db_log_path}",
    refreshonly => true,
  }

  class { mongodb::automation_agent::install:
    ops_manager_fqdn => $ops_manager_fqdn,
    url_svc_type     => $url_svc_type,
  }
  class { mongodb::automation_agent::config:
    mms_group_id     => $mms_group_id,
    mms_api_key      => Sensitive($mms_api_key),
    ops_manager_fqdn => $ops_manager_fqdn,
    url_svc_type     => $url_svc_type,
    require          => Class['mongodb::automation_agent::install']
  }
  class { mongodb::automation_agent::service:
    subscribe => Class['mongodb::automation_agent::config'],
  }
}
