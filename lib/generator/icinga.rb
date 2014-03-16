class IcingaHost
  include ERB::Util
  attr_accessor :host, :template, :collins_host

  def initialize(host, template, collins_host)
    @template = File.open(template, "rb").read
    @host = host
    @collins_host = collins_host
  end

  def render()
    ERB.new(@template).result(binding)
  end

  def save(file)
    File.open(file, "w+") do |f|
      f.write(render)
    end
  end
end