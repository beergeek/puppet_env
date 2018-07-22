#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'optparse'

options = {}
OptionParser.new do |parser|
  parser.on("-c", "--certname=CERTNAME",
            "A CERTNAME is required") do |certname|
    options[:certname] = certname;
  end
  parser.on("-m", "--master=MASTER_FQDN",
            "The master's FQDN is required") do |master|
    options[:master] = master;
  end
end.parse!

begin
  if options[:certname] == nil
    raise ArgumentError, "`certname` is required"
  end
  if options[:master] == nil
    raise ArgumentError, "`master` is required"
  end
  _stdout, _stderr, _status = Open3.capture3("puppet-task run autosign::generate_token certname=#{options[:certname]} --nodes #{options[:master]} --format json")
  if _status == 0
    output_hash = JSON.parse(_stdout)
    if output_hash['state'] == 'finished' and output_hash['items'][0]['results']['_output']
      output = output_hash['items'][0]['results']['_output']
      puts output.chomp
    else
      raise RuntimeError, "Failed to get output"
    end
  else
    raise RuntimeError, _stderr
  end
rescue StandardError => e
  raise "Major error: #{e}"
  exit -1
end