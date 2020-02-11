# Profile for Active Directory Domain Controllers
class profile::ad_services (
  Hash    $domain_controller_hash,
  Hash    $dns_server_hash,
  Boolean $collect_hosts             = true,
  Optional[Hash[
    String[1],
    Struct[{
      password                       => String[1],
      Optional[ensure]               => Enum['absent','present'],
      Optional[enabled]              => Boolean,
      Optional[passwordneverexpires] => Boolean,
      Optional[cannotchangepassword] => Boolean,
    }]
  ]]      $users                     = undef,
  Struct[{
    ensure                           => Enum['absent','present'],
    enabled                          => Boolean,
    passwordneverexpires             => Boolean,
    cannotchangepassword             => Boolean,
  }]      $user_defaults,
) {

  class { 'active_directory::domain_controller':
    domain_credential_passwd => Sensitive.new($domain_controller_hash['domain_credential_passwd']),
    safe_mode_passwd         => Sensitive.new($domain_controller_hash['safe_mode_passwd']),;
    default:
      *                      => $domain_controller_hash,
  }

  class { 'active_directory::dns_server':
    * => $dns_server_hash,
  }

  # Collection DNS entries from Non-Windows nodes and instantiate
  if $collect_hosts {
    Dsc_xdnsrecord <<| |>>
  }

  if $users {
    $users.each |String $username, Hash $user_data| {
      dsc_xaduser { $username:
        dsc_ensure               => $user_data['ensure'],
        dsc_username             => $username,
        dsc_domain               => $domain_controller_hash['domain_name'],
        dsc_password             => {
          'user'     => $username,
          'password' => Sensitive.new($user_data['password'])
        },
        dsc_enabled              => $user_data['enabled'],
        dsc_passwordneverexpires => $user_data['passwordneverexpires'],
        dsc_cannotchangepassword => $user_data['cannotchangepassword'],
      }
    }
  }

}
