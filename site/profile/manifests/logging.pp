class profile::logging (
  Hash $rsyslog_data,
  Hash $logrotate_rule_data,
) {

  if $::brownfields and $noop_scope {
    noop()
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
