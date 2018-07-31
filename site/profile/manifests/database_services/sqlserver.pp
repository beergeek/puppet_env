class profile::database_services::sqlserver (
  Hash $sql_source,
  String $sql_passwd,
  String $sql_user,
  Hash $db_hash,
  String $sql_version = 'MSSQL14',
  String $dotnet_src  = "C:\\vagrant\\sxs\\",
) {

  reboot { 'pre':
    apply => 'immediately',
    when  => 'pending',
  }

  reboot { 'right_now':
    apply => 'immediately',
    when  => 'pending',
  }

  dsc_xwindowsfeature { 'Net-Framework-Core':
    dsc_ensure => 'Present',
    dsc_name   => 'Net-Framework-Core',
    dsc_source => $dotnet_src,
    require    => [Service['wuauserv'],Reboot['pre']],
    notify     => Reboot['right_now'],
  }

  sqlserver_instance{'MSSQLSERVER':
    features              => ['SQL'],
    source                => $sql_source,
    security_mode         => 'SQL',
    sa_pwd                => $sql_passwd,
    sql_sysadmin_accounts => [$sql_user],
    require               => Reboot['right_now'],
  }

  sqlserver_features { 'Generic Features':
    source   => $sql_source,
    features => ['ADV_SSMS', 'BC', 'Conn', 'SDK', 'SSMS'],
    require  => Reboot['right_now'],
  }

  sqlserver::config { 'MSSQLSERVER':
    admin_user => 'sa',
    admin_pass => $sql_passwd,
  }

  $db_hash.each |String $key, Hash $value| {
    sqlserver::database { $key:
      instance => 'MSSQLSERVER',
    }
    sqlserver::login{ $key:
      password => $value['password'],
    }

    sqlserver::user{ $key:
      user     => $key,
      database => $key,
      require  => Sqlserver::Login[$key],
    }
  }

  windows_firewall::exception { 'Sql browser access':
    ensure       => present,
    direction    => 'in',
    action       => 'Allow',
    enabled      => 'yes',
    program      => 'C:\Program Files (x86)\Microsoft SQL Server\90\Shared\sqlbrowser.exe',
    display_name => 'MSSQL Browser',
    description  => 'MS SQL Server Browser Inbound Access',
  }

  windows_firewall::exception { 'Sqlserver access':
    ensure       => present,
    direction    => 'in',
    action       => 'Allow',
    enabled      => 'yes',
    program      => "C:\\Program Files\\Microsoft SQL Server\\${sql_version}.${db_instance}\\MSSQL\\Binn\\sqlservr.exe",
    display_name => 'MSSQL Access',
    description  => 'MS SQL Server Inbound Access',
  }
}
