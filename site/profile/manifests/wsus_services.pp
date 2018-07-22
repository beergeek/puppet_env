class profile::wsus_services (
  String $server_url,
  Profile::Wsus_auo $auto_update_option        = 'Scheduled',
  Profile::Day_of_week $scheduled_install_day  = 'Sunday',
  Profile::Hour_of_day $scheduled_install_hour = '13', # servers in UTC
  Boolean $enable_status_server                = true,
) {

  class { 'wsus_client':
    server_url             => $server_url,
    auto_update_option     => $auto_update_option,
    scheduled_install_hour => $scheduled_install_hour,
    scheduled_install_day  => $scheduled_install_day,
    enable_status_server   => $enable_status_server,
  }

}
