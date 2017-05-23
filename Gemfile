source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 4.10.1'
  gem "rspec"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "simplecov"
  gem "simplecov-console"
  gem "onceover", :git =>  'https://github.com/beergeek/onceover.git', :branch => 'shared_examples'
end
