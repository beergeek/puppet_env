class profile::docker (
  String         $version       = 'latest',
  Optional[Hash] $docker_images = undef,
) {

  class { 'docker':
    version => $version,
  }
}
