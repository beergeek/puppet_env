source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 5.5.3'
  gem "rspec"
  gem "rspec-puppet"
  gem "puppet-lint"
  gem "r10k"
  gem "puppetlabs_spec_helper"
  gem 'onceover', '>= 3.8.0'
  #gem 'onceover-gatekeeper', git: 'https://github.com/dylanratcliffe/onceover-gatekeeper.git'
end

group :pre do
  gem "puppet-lint"
end
