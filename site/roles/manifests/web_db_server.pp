class roles::web_db_server {

  include profiles::base
  include profiles::apache_php
  include profiles::mysql_php

}
