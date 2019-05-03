#
class profile::database_services::mongodb_nodb (
  Boolean                        $enable_firewall = true,
  Array[String[1]]               $firewall_ports  = ['27017'],
  Stdlib::Absolutepath           $base_data_path  = '/data',
  Stdlib::Absolutepath           $db_data_path    = '/data/db',
  Stdlib::Absolutepath           $db_log_path     = '/data/logs',
  String[1]                      $mms_group_id,
  Sensitive[String[1]]           $mms_api_key,
  String[1]                      $ops_manager_fqdn,
  Enum['http','https']           $url_svc_type    = 'http',
  Optional[Sensitive[String[1]]] $cluster_auth_pem_content,
  Optional[Sensitive[String[1]]] $pem_file_content,
  Optional[String[1]]            $ca_cert_pem_content,
  Optional[Stdlib::Absolutepath] $pki_dir,
  Optional[Stdlib::Absolutepath] $ca_file_path,
  Optional[Stdlib::Absolutepath] $pem_file_path,
  Optional[Stdlib::Absolutepath] $cluster_auth_file_path,
  Optional[Sensitive[String[1]]] $server_keytab_content,
  Optional[Stdlib::Absolutepath] $server_keytab_path,
  Optional[Sensitive[String[1]]] $client_keytab_content,
  Optional[Stdlib::Absolutepath] $client_keytab_path,
  String[1]                      $svc_user,
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

  file { [$base_data_path, $db_data_path, $db_log_path, $pki_dir]:
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
    mms_api_key      => $mms_api_key,
    ops_manager_fqdn => $ops_manager_fqdn,
    url_svc_type     => $url_svc_type,
    require          => Class['mongodb::automation_agent::install']
  }
  class { mongodb::supporting:
    cluster_auth_pem_content => $cluster_auth_pem_content,
    pem_file_content         => $pem_file_content,
    ca_cert_pem_content      => $ca_cert_pem_content,
    pki_dir                  => $pki_dir,
    ca_file_path             => $ca_file_path,
    pem_file_path            => $pem_file_path,
    cluster_auth_file_path   => $cluster_auth_file_path,
    svc_user                 => $svc_user,
    server_keytab_content    => $server_keytab_content,
    server_keytab_path       => $server_keytab_path,
    client_keytab_content    => $client_keytab_content,
    client_keytab_path       => $client_keytab_path,
    before                   => Class['mongodb::automation_agent::service'],
  }
  class { mongodb::automation_agent::service:
    subscribe => Class['mongodb::automation_agent::config'],
  }
}
