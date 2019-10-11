#
# Remember '/etc/krb5.conf' and '/etc/openldap/ldap.conf'!
class profile::database_services::mongodb (
  Optional[Sensitive[String[1]]] $client_keytab_content,
  Optional[Sensitive[String[1]]] $cluster_auth_pem_content,
  Optional[Sensitive[String[1]]] $keyfile_content,
  Optional[Sensitive[String[1]]] $pem_file_content,
  Optional[Sensitive[String[1]]] $server_keytab_content,
  Optional[Stdlib::Absolutepath] $ca_file_path,
  Optional[Stdlib::Absolutepath] $client_keytab_path,
  Optional[Stdlib::Absolutepath] $cluster_auth_file_path,
  Optional[Stdlib::Absolutepath] $pem_file_path,
  Optional[Stdlib::Absolutepath] $pki_path,
  Optional[Stdlib::Absolutepath] $server_keytab_path,
  Optional[String[1]]            $ca_cert_pem_content,
  Stdlib::Absolutepath           $base_path,
  Stdlib::Absolutepath           $db_base_path,
  Stdlib::Absolutepath           $log_path,
  String[1]                      $svc_user,
  Boolean                        $enable_firewall   = true,
  Boolean                        $manage_kerberos   = true,
  Boolean                        $manage_ldap       = true,
  Optional[Sensitive[String[1]]] $ldap_bind_password,
  Hash[
    String[1],
    Struct[{
      Optional[keytab_file_path]    => Boolean,
      Optional[enable_kerberos]     => Boolean,
      Optional[enable_ldap_authn]   => Boolean,
      Optional[enable_ldap_authz]   => Boolean,
      Optional[ldap_authz_query]    => String[1],
      Optional[ldap_bind_username]  => String[1],
      Optional[ldap_servers]        => String[1],
      Optional[ldap_user_mapping]   => String[1],
      Optional[ldap_security]       => Enum['none','tls'],
      Optional[kerberos_trace_path] => Optional[Stdlib::Absolutepath],
      Optional[keyfile_path]        => Optional[Stdlib::Absolutepath],
      Optional[keytab_file_path]    => Optional[Stdlib::Absolutepath],
      Optional[wiredtiger_cache_gb] => String[1],
      Optional[repsetname]          => String[1],
      Optional[svc_user]            => String[1],
      Optional[conf_file]           => Stdlib::Absolutepath,
      Optional[bindip]              => String[1],
      Optional[port]                => String[1],
      Optional[log_filename]        => String[1],
      Optional[auth_list]           => String[1],
      Optional[base_path]           => Stdlib::Absolutepath,
      Optional[db_base_path]        => Stdlib::Absolutepath,
      Optional[db_data_path]        => Stdlib::Absolutepath,
      Optional[log_path]            => Stdlib::Absolutepath,
      Optional[pid_file]            => Stdlib::Absolutepath,
      Optional[pki_path]            => Stdlib::Absolutepath,
      Optional[member_auth]         => Enum['x509', 'keyFile', 'none'],
      Optional[ssl_mode]            => Enum['requireSSL','preferSSL','none'],
      Optional[pem_file]            => Optional[Stdlib::Absolutepath],
      Optional[cluster_pem_file]    => Optional[Stdlib::Absolutepath],
      Optional[ca_file]             => Stdlib::Absolutepath,
    }]
  ]  $mongod_instance,

  # automation agent
  Boolean                        $install_aa,
  Boolean                        $enable_ssl,
  String[1]                      $mms_group_id,
  Sensitive[String[1]]           $mms_api_key,
  String[1]                      $ops_manager_fqdn,
  Enum['http','https']           $url_svc_type,
  Optional[Stdlib::Absolutepath] $aa_ca_file_path,
  Optional[Stdlib::Absolutepath] $aa_pem_file_path,
  Optional[Sensitive[String[1]]] $aa_pem_file_content,
  Optional[String[1]]            $aa_ca_cert_content    = $ca_cert_pem_content,
) {

  require mongodb::repos
  require mongodb::os

  if $manage_kerberos {
    require profile::kerberos
  }

  if $manage_ldap {
    require profile::ldap
  }
  class { 'mongodb::install':
    require => Class['mongodb::supporting'],
  }

  class { 'mongodb::supporting':
    base_path                => $base_path,
    ca_cert_pem_content      => $ca_cert_pem_content,
    ca_file_path             => $ca_file_path,
    cluster_auth_file_path   => $cluster_auth_file_path,
    cluster_auth_pem_content => $cluster_auth_pem_content,
    db_base_path             => $db_base_path,
    log_path                 => $log_path,
    keyfile_content          => $keyfile_content,
    pem_file_content         => $pem_file_content,
    pem_file_path            => $pem_file_path,
    pki_path                 => $pki_path,
    server_keytab_content    => $server_keytab_content,
    server_keytab_path       => $server_keytab_path,
    svc_user                 => $svc_user,
  }

  $mongod_instance.each |String $instance_name, Hash $instance_data| {

    if $instance_data['enable_kerberos'] {
      require profile::kerberos
    }

    if $instance_data['enable_ldap_authn'] {
      require profile::ldap
    }

    if $instance_data['enable_ldap_authz'] {
      require profile::ldap
    }

    mongodb::config { $instance_name:
      *                  => $instance_data,
      ldap_bind_password => $ldap_bind_password,
      before             => Mongodb::Service[$instance_name],
      require            => Class['mongodb::install'],
    }

    if $enable_firewall {
      if $instance_data['port'] {
        $_port = $instance_data['port']
      } else {
        $_port = '27017'
      }
      # firewall rules
      firewall { "101 allow mongodb ${instance_name} access":
        dport  => [$_port],
        proto  => tcp,
        action => accept,
      }
    }

    if $instance_data['spn'] {
      if $instance_data['svc_account'] {
        @@dsc_xadserviceprincipalname { $instance_data['spn']:
          ensure      => present,
          dsc_account => $instance_data['svc_account'],
        }
      } else {
        fail('A service account is required to create a SPN')
      }
    }

    mongodb::service { $instance_name:
      require => Class['mongodb::supporting'],
    }
  }

  if $install_aa {
    class { 'mongodb::automation_agent':
      ops_manager_fqdn => $ops_manager_fqdn,
      url_svc_type     => $url_svc_type,
      mms_group_id     => $mms_group_id,
      mms_api_key      => $mms_api_key,
      enable_ssl       => $enable_ssl,
      ca_file_path     => $aa_ca_file_path,
      pem_file_path    => $aa_pem_file_path,
      pem_file_content => $aa_pem_file_content,
      ca_file_content  => $aa_ca_cert_content,
    }
  }

}
