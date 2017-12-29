class profile::logging (
  Hash $rsyslog_data,
  Hash $logrotate_rule_data,
  Optional[Boolean] $noop_scope,
) {

  if $noop_scope {
    noop(true)
  }

  class { '::rsyslog::client':
    * => $rsyslog_data,
  }

  ::logrotate::rule { 'all_log':
    *          => $logrotate_rule_data,
    path       => '/var/log/*/*',
    compress   => true,
    postrotate => '/usr/bin/killall -HUP rsyslog',
  }
}
