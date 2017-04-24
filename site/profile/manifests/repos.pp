class profile::repos (
  Optional[Hash] $repo_hash          = undef,
  Optional[Hash] $repo_default_hash  = undef,
  Boolean $collect_repos             = true,
  Boolean $noop_scope                = false,
) {

  if $::brownfields and $noop_scope {
    noop()
  }

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
