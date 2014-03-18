require 'collins_auth'
require 'erb'
require 'pp'

require 'generator/fromtemplate.rb'

class Generator
  def initialize
    @basedir = File.expand_path '~/Documents/blendle_config/icinga'
    config = YAML.load_file File.expand_path "~/.collins.blendle.yaml"
    @collins = Collins::Authenticator.setup_client config, false
  end
  
  def find options = {}
    options.merge!(:details => true, :size => 5000)
    
    @collins.find options
  end
  
  def collins_host
    @collins.host
  end
  
  def generate_icinga_configs
    # Find all nodes in icinga
    hosts = self.find :status => "Allocated", :hostname => "*", :query => "TYPE = SERVER_NODE OR TYPE = SWITCH OR TYPE = ROUTER OR TYPE = POWER_STRIP"
    
    # Initialize hashes
    nodeclass = {}
    nodeclass['TYPE:all'] = []
    
    hosts.each do |host|
      nodeclass["NODECLASS:#{host.nodeclass}"] = [] unless nodeclass.has_key?("NODECLASS:#{host.nodeclass}")
      nodeclass["NODECLASS:#{host.nodeclass}"] << host.hostname
      
      nodeclass["TYPE:#{host.type}"] = [] unless nodeclass.has_key?("TYPE:#{host.type}")
      nodeclass["TYPE:#{host.type}"] << host.hostname
      nodeclass['TYPE:all'] << host.hostname
    end
    
    GenerateFromTemplate.new(hosts, "templates/host.erb", collins_host, "#{@basedir}/hosts.cfg")
    GenerateFromTemplate.new(nodeclass, "templates/hostgroup.erb", collins_host, "#{@basedir}/hostgroups.cfg")
  end
end