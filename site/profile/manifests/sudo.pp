class profile::sudo (
  Hash $sudo_hash,
  Hash $sudo_hash_defaults,
  Boolean $sudo_purge,
  Boolean $sudo_replace_config,
  Optional[Boolean] $noop_scope,
) {

  if $noop_scope {
    noop(true)
  }

  class { '::sudo':
    purge               => $sudo_purge,
    config_file_replace => $sudo_replace_config,
  }

  $sudo_hash.each |String $sudo_name,Hash $sudo_hash_value| {
    sudo::conf { $sudo_name:
      * => $sudo_hash_value,;
      default:
        * => $sudo_hash_defaults;
    }
  }
}
