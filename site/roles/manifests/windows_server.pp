class roles::windows_server {

  include profiles::ntp_client
  include profiles::java
  include profiles::iis

}
