require 'simplecov'
require 'simplecov-console'

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'metadata-json-lint/rake_task'
require 'puppetlabs_spec_helper/module_spec_helper'
RSpec.configure do |c|
  c.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  #c.after(:suite) do
  #  RSpec::Puppet::Coverage.report!()
  #end
end
