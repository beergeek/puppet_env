#
class profile::mongodb_auditor (
  Optional[Struct[{
    audit_db_connection_string            => Profile::MongoDBURL,
    om_db_connection_string               => Profile::MongoDBURL,
    event_watcher_dir                     => Stdlib::Absolutepath,
    Optional[enable_audit_db_ssl]         => Boolean,
    Optional[enable_om_db_ssl]            => Boolean,
    Optional[enable_debugging]            => Boolean,
    Optional[enable_kerberos_debugging]   => Boolean,
    Optional[kerberos_file_path]          => Optional[Stdlib::Absolutepath],
    Optional[kerberos_trace_path]         => Optional[Stdlib::Absolutepath],
    Optional[audit_db_ssl_pem_file_path]  => Optional[Stdlib::Absolutepath],
    Optional[audit_db_ssl_ca_file_path]   => Optional[Stdlib::Absolutepath],
    Optional[om_db_ssl_pem_file_path]     => Optional[Stdlib::Absolutepath],
    Optional[om_db_ssl_ca_file_path]      => Optional[Stdlib::Absolutepath],
    Optional[script_owner]                => String[1],
    Optional[script_group]                => String[1],
    Optional[script_mode]                 => String[1],
    Optional[audit_db_timeout]            => Integer[1],
    Optional[om_db_timeout]               => Integer[1],
    Optional[change_stream_pipeline]      => String[1],
  }]]                             $ops_manager_event_watcher,
) {

  class { 'mongodb_audit_tools::ops_manager_event_watcher':
    *       => $ops_manager_event_watcher,
    require => Class['mongodb::supporting'],
  }

}
