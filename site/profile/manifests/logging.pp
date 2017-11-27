class profile::logging (
  Hash $rsyslog_data,
  Hash $logrotate_rule_data,
  Boolean $noop_scope = false,
) {

  if $facts['brownfields'] and $noop_scope {
    noop(true)
  } else {
    noop(false)
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
