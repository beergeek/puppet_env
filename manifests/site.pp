node /^vcac-sdl-web-{\d+4}/ {
  include role::webserver
}

node /^vcac-sdl-db-{\d+4}/ {
  include role::dbserver
}

node default {

  include profiles::base

}
