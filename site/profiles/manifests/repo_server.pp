class profiles::repo_server {

  $repo_data      = hiera_hash('profiles::repo_server::repo_data')
  $repo_defaults  = hiera('profiles::repo_server::repo_defaults')

  include profiles::web_services

  $repo_data.each |String $repo_name, Hash $repo_hash| {
    @@yumrepo { $repo_name:
      * => $repo_hash,;
      defaults:
        * => $repo_defaults,;
    }
  }

}
