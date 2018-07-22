class profile::docker (
  String $version = 'latest',
) {

  class { 'docker':
    version => $version,
  }
}
