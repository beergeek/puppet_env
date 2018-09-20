#
class profile::pipelines (
  Boolean                          $run_artifactory        = false,
  Array[Enum['pfa','pfc','cd4pe']] $pipeline_type          = ['pfa','pfc','cd4pe'],
  String                           $docker_network_name    = 'pipelines',
  Stdlib::IP::Address::V4::CIDR    $docker_network_subnet  = '192.168.168.0/24',
  Stdlib::IP::Address::Nosubnet    $docker_network_gateway = '192.168.168.1',
  Array[String]                    $pfa_ports              = ['8080:8080','8000:8000','7000:7000'],
  Array[String]                    $pfc_ports              = ['8080:8080','8000:8000','7000:7000'],
  Array[String]                    $cd4pe_ports            = ['8080:8080','8000:8000','7000:7000'],
  Array[String]                    $artifactory_ports      = ['8081:8081'],
  Optional[Array[String]]          $pfa_env_params         = ['USER=pfa',"MYSQL_PWD=P@ssword123", "DB_ENDPOINT=mysql://192.168.0.23:3306/pfa"]
) {

  include profile::docker

  docker_network { $docker_network_name:
    ensure  => present,
    subnet  => $docker_network_subnet,
    gateway => $docker_network_gateway,
  }

  if 'pfc' in $pipeline_type {
    docker::image { 'puppet/pipelines-for-containers':
      tag => 'latest',
    }
    docker::run { 'pfc':
      image                     => 'puppet/pipelines-for-containers:latest',
      detach                    => true,
      ports                     => $pfc_ports,
      net                       => $docker_network_name,
      remove_container_on_stop  => true,
    }
  }
  if 'pfa' in $pipeline_type {
    docker::image { 'puppet/pipelines-for-applications':
      tag => 'latest',
    }
    docker::run { 'pfa':
      image                     => 'puppet/pipelines-for-applications:latest',
      detach                    => true,
      ports                     => $pfa_ports,
      net                       => $docker_network_name,
      remove_container_on_stop  => true,
      env                       => $pfa_env_params,
    }
  }
  if 'cd4pe' in $pipeline_type { 
    docker::image { 'puppet/continuous-delivery-for-puppet-enterprise':
      tag => 'latest',
    }
    docker::run { 'cd4pe':
      image                     => 'puppet/continuous-delivery-for-puppet-enterprise:latest',
      detach                    => true,
      ports                     => $cd4pe_ports,
      net                       => $docker_network_name,
      remove_container_on_stop  => true,
    }
  }
  if $run_artifactory {
    docker::image { 'docker.bintray.io/jfrog/artifactory-oss':
      tag => '5.8.3',
    }
    docker::run { 'cd4pe':
      image                     => 'docker.bintray.io/jfrog/artifactory-oss:5.8.3',
      detach                    => true,
      ports                     => $artifactory_ports,
      net                       => $docker_network_name,
      remove_container_on_stop  => false,
    }
  }
}
