require 'spec_helper'

describe HoptoadNotifier do
  describe '.notify_or_ignore' do
    
    context 'with an exception' do
      let(:api_url) { HoptoadNotifier::Sender.new(HoptoadNotifier.configuration).instance_eval { url }.to_s }
      let(:build_notice) { HoptoadNotifier.instance_eval { build_notice_for(Exception.new("blah blah")) } }
      

      it 'should send to the old url of /notices/' do
        api_url.should match(/notices\//)
      end
      
      it "should not send to the new api url" do
        api_url.should_not match(/notices_api/)
      end
      
      it "should send data to url in yaml form" do
        build_notice.should match(/\-\-\-/)
      end
      
      it "should not send data xml form" do
        build_notice.should_not match(/^\</)
      end
      
      it "should set headers to yaml content type" do
        HoptoadNotifier::HEADERS["Content-type"].should match(/yaml/)
      end

      it "should not set headers to xml content type" do
        HoptoadNotifier::HEADERS["Content-type"].should_not match(/xml/)
      end

      it "the root of the notice should be 'notice'" do
        HoptoadNotifier.instance_eval do 
          clean_notice(normalize_notice(Exception.new("blah blah"))) 
        end.keys.should == [:notice]
      end
    end
  end
end