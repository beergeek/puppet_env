class profile::testing_class (
  String $test_content = 'abcdefg',
) {

  file { '/tmp/test':
    ensure  => file,
    content => $test_content,
  }
}
