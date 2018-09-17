#
class profile::pipelines (
  Enum['pfa','pfc'] $pipeline_type = 'pfc',
) {

  case $pipeline_type {
    'pfc': {}
    'pfa': {}
    default: {
      fail("Can only be 'pfc' or 'pfa', not ${pipeline_type}")
    }
  }

  include profile::docker
}
