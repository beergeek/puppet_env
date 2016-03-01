class role::syd_f5_load_balancer {

  $vlans          = hiera('role::syd_f5_load_balancer::vlans')
  $vlan_defaults  = hiera('role::syd_f5_load_balancer::vlan_defaults')

  #create resources for VLANS
  create_resources('f5_v11_vlan',$vlans,$vlan_defaults)

  F5_v11_node {
	  state       => 'user-up',
	  session     => 'user-enabled',
  }

	f5_v11_node {'test_node_0':
	  ensure      => present,
	  ipaddress   => '192.168.62.110',
	  description => "This is our test node 0",
	}

	f5_v11_node {'test_node_1':
	  ensure      => present,
	  ipaddress   => '192.168.62.111',
	  description => "This is our test node 1",
	}

	f5_v11_node {'test_node_2':
	  ensure        => present,
	  ipaddress     => '192.168.62.112',
	  description   => "This is our test node 2",
	  dynamic_ratio => 2 ,
	}

	f5_v11_node {'test_node_3':
	  ensure      => present,
	  ipaddress   => '192.168.62.113',
	  description => "This is our test node 3",
	}

	f5_v11_pool {'test_pool_0':
	  ensure           => present,
	  members          => ['test_node_0:80','test_node_1:80'],
	  description      => "A test pool",
	  lb_method        => 'fastest-node',
	  allow_nat_state  => 'yes',
	  allow_snat_state => 'no',
	  require          => [F5_v11_node['test_node_0'],F5_v11_node['test_node_1']],
	}

	f5_v11_pool {'test_pool_1':
	  ensure                  => present,
	  description             => 'This is the description of the pool',
	  action_on_service_down  => 'reset',
	  allow_nat_state         => 'no',
	  allow_snat_state        => 'yes',
	  client_ip_tos           => 'pass-through',
	  client_link_qos         => '2',
	  lb_method               => 'fastest-node',
	  members                 => ['test_node_2:80','test_node_3:80'],
	  server_ip_tos           => '5',
	  server_link_qos         => 'pass-through',
	  slow_ramp_time          => '10',
	  require                 => [F5_v11_node['test_node_2'],F5_v11_node['test_node_3']],
	}

	f5_v11_virtualserver {"test_virtual_server_0":
	  ensure      => present,
	  destination => '192.168.111.2',
	  port        => '8281',
	  pool        => 'test_pool_0',
	  protocol    => 'tcp',
    require    => F5_v11_pool['test_pool_0'],
	}
}	
