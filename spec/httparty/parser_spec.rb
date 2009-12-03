require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

class CustomParser
  include HTTParty::Parser
  parses_format 'application/atom+xml' => :atom
  
  def json
    {:sexy => false}
  end
  
  def atom
    {:sexy => :possibly}
  end
end

describe HTTParty::Parser do
  
  before(:each) do
    @klass = Class.new
    @klass.instance_eval { include HTTParty }
    @parser = CustomParser
    @klass.parser @parser
  end
  
  it "should be able to parse response" do
    FakeWeb.register_uri(:get, 'http://twitter.com/statuses/public_timeline.html', :body => 'tweets', :content_type => 'text/html')
    custom_parsed_response = @klass.get('http://twitter.com/statuses/public_timeline.html')
    custom_parsed_response.should == 'tweets'
  end

  it "should be able parse response with custom parser" do
    FakeWeb.register_uri(:get, 'http://twitter.com/statuses/public_timeline.json', :body => 'tweets', :content_type => 'text/json')
    custom_parsed_response = @klass.get('http://twitter.com/statuses/public_timeline.json')
    custom_parsed_response[:sexy].should == false
  end
  
  it "should be able parse response with HTTParty default parser if not defined in a custom parser" do
    FakeWeb.register_uri(:get, 'http://twitter.com/statuses/public_timeline.xml', :body => '<tweet>hi!</tweet>', :content_type => 'text/xml')
    custom_parsed_response = @klass.get('http://twitter.com/statuses/public_timeline.xml')
    custom_parsed_response['tweet'].should == 'hi!'
  end
  
  it "should be able parse response from a custom mimetype" do  
    FakeWeb.register_uri(:get, 'http://twitter.com/statuses/public_timeline.atom', :body => 'tweets', :content_type => 'application/atom+xml')
    custom_parsed_response = @klass.get('http://twitter.com/statuses/public_timeline.atom')
    custom_parsed_response[:sexy].should == :possibly
  end
  
  it "should not add new formats to HTTParty::Parser::Base when defining a custom format in a custom parser" do
    HTTParty::Parser::Base.allowed_formats.has_key?('application/atom+xml').should be_false
  end
  
end