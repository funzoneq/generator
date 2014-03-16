class GenerateFromTemplate
  include ERB::Util
  attr_accessor :host, :template, :collins_host, :extras

  def initialize(host, template, collins_host, extras = {})
    @template = File.open(template, "rb").read
    @host = host
    @collins_host = collins_host
    @extras = extras
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