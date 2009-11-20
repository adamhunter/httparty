class HTTParty::Parser
  def self.call(body, format)
    new(body, format).parse
  end
  
  def initialize(body,format)
    @body = body
    @format = format
  end
  private_class_method :new
  
  def parse
    return @body unless @format
    send @format
  rescue NoMethodError
    raise HTTParty::UnsupportedFormat, "HTTParty::Parser does not support the #{@format.inspect} format."
  end
  
  def xml
    Crack::XML.parse(@body)
  end
  
  def json
    Crack::JSON.parse(@body)
  end
  
  def yaml
    ::YAML.load(@body)
  end
  
  def html
    @body
  end
  
  def text
    @body
  end

end