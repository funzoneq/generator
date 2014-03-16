require 'collins_auth'
require 'erb'

require 'generator/icinga.rb'

class Generator
  def initialize
    config = YAML.load_file File.expand_path "~/.collins.blendle.yaml"
    @collins = Collins::Authenticator.setup_client config, false
  end
  
  def find options = {}
    options.merge(:details => true)
    @collins.find options
  end
  
  def collins_host
    @collins.host
  end
  
  def generate_icinga_configs
    hosts = self.find :status => "Allocated", :hostname => "*"
    
    hosts.each do |host|
      h = IcingaHost.new(host, "templates/host.erb", collins_host)
      h.save("host-#{host.hostname}.cfg")
    end
  end
end