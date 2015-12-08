class roles::db_server {

  require profiles::base
  include profiles::database_services

}
