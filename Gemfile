source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.10.1'
  gem "rspec"
  gem "rspec-puppet"
  gem "puppetlabs_spec_helper"
  gem 'onceover', '>= 3.3.2'
#  gem 'onceover', git: 'https://github.com/beergeek/onceover.git', branch: 'improve_plugin_support'
  gem 'onceover-gatekeeper', git: 'https://github.com/dylanratcliffe/onceover-gatekeeper.git'
#  gem 'onceover-gatekeeper', git: 'https://github.com/beergeek/onceover-gatekeeper.git', branch: 'fix_for_new_rspec'
  #gem "onceover", :git =>  'https://github.com/beergeek/onceover.git', :branch => 'shared_examples'
  gem "xmlrpc"
end

group :pre do
  gem "puppet-lint"
end
