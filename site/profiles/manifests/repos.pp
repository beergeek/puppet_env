class profiles::repos {

  $repo_hash          = hiera_hash('profiles::repos::repo_hash', undef)
  $repo_default_hash  = hiera('profiles::repos::repo_default_hash', undef)

  if $repo_hash and $repo_default_hash {
    create_resources('yumrepo', $repo_hash, $repo_default_hash)
  }

  Yumrepo <<| |>>

  Yumrepo['custom_packages'] -> Package <| tag == 'custom' |>

}
