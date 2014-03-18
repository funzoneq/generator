class GenerateFromTemplate
  include ERB::Util
  attr_accessor :items, :template, :collins_host

  def initialize(items, template, collins_host, file)
    @template = File.open(template, "rb").read
    @items = items
    @collins_host = collins_host
    
    self.save(file)
  end

  def render()
    ERB.new(@template).result(binding)
  end
  
  def primary_address asset
    if asset.backend_ip_address
      return asset.backend_address
    elsif asset.addresses.size > 0
      return asset.addresses.first
    end
    nil
  end

  def save(file)
    File.open(file, "w+") do |f|
      f.write(render)
    end
  end
end