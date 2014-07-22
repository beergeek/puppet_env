node /^vcac-sdl-web-{\d+4}/ {
  include role::frontend_webserver
}

node /^vcac-sdl-db-{\d+4}/ {
  include role::backend_dbserver
}

node default {

  include profiles::base

}
