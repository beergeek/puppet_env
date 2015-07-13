class profiles::web_services {

  $website_hash 	= hiera_hash('profiles::web_services::website_hash')
  $website_defaults 	= hiera('profiles::web_services::website_defaults')

  ensure_packages(['git'])

  Profiles::Web_sites {
    require => Package['git'],
  }

  #build base web server
  require apache
  require apache::mod::php
  require apache::mod::ssl

  #create web sites
  create_resources('profiles::web_sites',$website_hash,$website_defaults)

  # add firewall rules
  firewall { '100 allow http and https access':
    port   => [80, 443],
    proto  => tcp,
    action => accept,
  }

}
