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
    hosts = self.find :status => "Allocated", :hostname => "*"
    nodeclass = {}
    nodeclass['all'] = []
    
    hosts.each do |host|
      nodeclass[host.nodeclass] = [] unless nodeclass[host.nodeclass].kind_of?(Array)
      nodeclass[host.nodeclass] << host.hostname
      nodeclass['all'] << host.hostname
      
      h = GenerateFromTemplate.new(host, "templates/host.erb", collins_host)
      h.save("#{@basedir}/hosts/#{host.hostname}.cfg")
    end
    
    nodeclass.each do |nc,host|
      h = GenerateFromTemplate.new(host, "templates/hostgroup.erb", collins_host, { :nodeclass => nc })
      h.save("#{@basedir}/hostgroups/#{nc}.cfg")
    end
  end
end