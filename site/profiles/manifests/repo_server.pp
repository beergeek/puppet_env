class profiles::repo_server {

  $repo_url = hiera('profiles::repo_server::repo_url')

  include profiles::web_services

  @@yumrepo { 'demo_repo':
    ensure   => present,
    enable   => '1',
    descr    => 'Demo env repo',
    baseurl  => $repo_url,
    gpgcheck => '0',
  }

}
