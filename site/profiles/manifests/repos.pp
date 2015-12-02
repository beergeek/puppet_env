class profiles::repos {

  $repo_hash          = hiera_hash('profiles::repos::repo_hash', undef)
  $repo_default_hash  = hiera('profiles::repos::repo_default_hash', undef)
  $collect_repos      = hiera('profiles::repos::collect_repos', true)

  if $repo_hash and $repo_default_hash {
    # old school
    # create_resources('yumrepo', $repo_hash, $repo_default_hash)
    # new school
    $repo_hash.each |String $repo_name, Hash $repo_values_hash| {
      yumrepo { $repo_name:
        * => $repo_values_hash,;
        default:
          * => $repo_default_hash,;
      }
    }
  }

  if $collect_repos {
    Yumrepo <<| |>>

    Yumrepo<| tag == 'custom_packages'|> -> Package <| tag == 'custom' |>
  }
}
