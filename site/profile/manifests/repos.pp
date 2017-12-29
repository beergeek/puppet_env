class profile::repos (
  Optional[Hash] $repo_hash          = undef,
  Optional[Hash] $repo_default_hash  = undef,
  Boolean $collect_repos             = true,
  Optional[Boolean] $noop_scope,
) {

  if $noop_scope {
    noop(true)
  }

  if $repo_hash and $repo_default_hash {
    $repo_hash.each |String $repo_name, Hash $repo_values_hash| {
      yumrepo { $repo_name:
        * => $repo_values_hash,;
        default:
          * => $repo_default_hash;
      }
    }
  }

  if $collect_repos {
    Yumrepo <<| |>>

    Yumrepo<| tag == 'custom_packages'|> -> Package <| tag == 'custom' |>
  }
}
