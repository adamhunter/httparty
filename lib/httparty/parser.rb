module HTTParty::Parser
  
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
    base.send :private_class_method, :new
    base.send :class_variable_set, "@@allowed_formats",
      'text/xml'               => :xml,
      'application/xml'        => :xml,
      'application/json'       => :json,
      'text/json'              => :json,
      'application/javascript' => :json,
      'text/javascript'        => :json,
      'text/html'              => :html,
      'application/x-yaml'     => :yaml,
      'text/yaml'              => :yaml,
      'text/plain'             => :plain
  end

  module ClassMethods
    
    def call(body, format)
      new(body, format).parse
    end
    
    def parses_format(format)
      allowed_formats.merge! format
    end
    
    def allowed_formats
      class_variable_get "@@allowed_formats"
    end
  end

  module InstanceMethods
    def initialize(body,format)
      @body = body
      @format = format
    end
    
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
  
  class Base
    include HTTParty::Parser
  end

end