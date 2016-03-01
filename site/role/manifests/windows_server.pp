class role::windows_server {

  include profile::ntp_client
  include profile::java
  include profile::iis

}
