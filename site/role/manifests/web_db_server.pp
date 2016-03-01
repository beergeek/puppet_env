class role::web_db_server {

  include profile::base
  include profile::apache_php
  include profile::mysql_php

}
