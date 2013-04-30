require 'spec_helper'

describe Incoming::Strategies::Mailgun do
  let(:receiver) { test_receiver(:api_key => 'asdf') }

  before do
    attachment = stub(:original_filename => 'hello.txt', :read => 'hello world')

    @params = {
      'recipient' => 'jack@example.com',
      'sender' => 'japhy@example.com',
      'from' => 'japhy@example.com',
      'subject' => 'Matterhorn',
      'body-plain' => "We should do that again sometime.\n> Quoted part",
      'body-html' => '<strong>We should do that again sometime.</strong>\r\n> <em>Quoted part</em>',
      'stripped-text' => 'We should do that again sometime.',
      'stripped-html' => '<strong>We should do that again sometime.</strong>',
      'signature' => 'foo',
      'message-headers' => '{}',
      'attachment-count' => '1',
      'attachment-1' => attachment
    }

    @mock_request = stub()
    @mock_request.stub(:params).and_return(@params)
  end

  describe 'non-mime request' do
    describe 'receive' do
      subject { receiver.receive(@mock_request) }
      before(:each) { OpenSSL::HMAC.stub(:hexdigest).and_return('foo') }

      it { should be_a Mail::Message }

      its('to.first') { should eq @params['recipient'] }
      its('from.first') { should eq @params['sender'] }
      its('subject') { should eq @params['subject'] }
      its('body.decoded') { should eq @params['body-plain'] }
      its('text_part.body.decoded') { should eq @params['body-plain'] }
      its('html_part.body.decoded') { should eq @params['body-html'] }
      its('attachments.first.filename') { should eq 'hello.txt' }
      its('attachments.first.read') { should eq 'hello world' }

      context 'stripped option is true' do
        let(:receiver) { test_receiver(:api_key => 'asdf', :stripped => true) }

        it { should be_a Mail::Message }

        its('body.decoded') { should eq @params['stripped-text'] }
        its('text_part.body.decoded') { should eq @params['stripped-text'] }
        its('html_part.body.decoded') { should eq @params['stripped-html'] }
      end
    end
  end

  it 'returns false from #authenticate when hexidigest is invalid' do
    OpenSSL::HMAC.stub(:hexdigest).and_return('bar')
    mailgun = receiver.new(@mock_request)
    mailgun.authenticate.should be_false
  end

  it 'authenticates when hexidigest is valid' do
    OpenSSL::HMAC.stub(:hexdigest).and_return('foo')
    mailgun = receiver.new(@mock_request)
    mailgun.authenticate.should be_true
  end

  it 'raises an exception when api key is not provided' do
    expect {
      test_receiver(:api_key => nil).new(@mock_request)
    }.to raise_error Incoming::Strategy::RequiredOptionError
  end
end
