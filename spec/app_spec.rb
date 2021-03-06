require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'monit-aggregator-server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application    
  end
  
  it "should give success when I request the index with valid authentication" do
    get '/', {}, {'HTTP_AUTHORIZATION'=> encode_credentials('admin', 'password')}
    last_response.should be_ok
  end
  
  it "should give a 401 when no authentication credentials" do
    get '/'
    last_response.status.should eql(401)
  end
  
  it "should give a 401 when bad authentication credentials" do
    get '/', {}, {'HTTP_AUTHORIZATION'=> encode_credentials('admin', 'badpassword')}
    last_response.status.should eql(401)
  end
  
end


describe "helpers" do
  describe "friendly_seconds" do
    it "should return days, hours and minutes when the passed in timestamp is more than a day old" do       
      friendly_seconds(582660).should eql("6d 17h 51m")
    end
    
    it "should return hours and minutes when the passed in timestamp is a few hours old" do       
      friendly_seconds(49380).should eql("13h 43m")
    end
    
    it "should return munites if under 1 hour" do
      friendly_seconds(1568).should eql("26m")
    end
  end
  
  describe "status_text" do
    it "should be 'Ok' if the service is up" do
      doc = Nokogiri::XML.parse('<service type="3">
      <collected>1246618801</collected>
      <name>mysql</name>
      <status>0</status>
      <monitor>1</monitor>
      <pendingaction>0</pendingaction>
      <group>mysql</group>
      <pid>4588</pid>
      <ppid>4545</ppid>
      <uptime>672915</uptime>
      <children>0</children>
      <memory>
      <kilobyte>45088</kilobyte>
      <kilobytetotal>45088</kilobytetotal>
      <percent>4.3</percent>
      <percenttotal>4.3</percenttotal>
      </memory>
      <cpu>
      <percent>0.0</percent>
      <percenttotal>0.0</percenttotal>
      </cpu>
      <port>
      <hostname>127.0.0.1</hostname>
      <port>3306</port>
      <request/>
      <type>TCP</type>
      <protocol>DEFAULT</protocol>
      <responsetime>0.000</responsetime>
      </port>
      </service>')
      status_text(doc).should eql('Ok')
    end
    
    it "should be 'Down' if the service doesn't have a pid" do
      doc = Nokogiri::XML.parse('<service type="3">
      <collected>1246618801</collected>
      <name>postfix</name>
      <status>0</status>
      <monitor>0</monitor>
      <pendingaction>0</pendingaction>
      <group>postfix</group>
      </service>')
      status_text(doc).should eql('Down')
    end
  end
end







