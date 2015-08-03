require 'spec_helper'

describe Rdio::Helper::Client do
  subject { described_class.new }

  describe '#fetch_authorization_endpoint' do
    specify do
      authorization_endpoint = subject.fetch_authorization_endpoint('http://example.com/redirect')
      expect(authorization_endpoint).to include ENV['RDIO_CLIENT_ID']
    end
  end

  describe '#fetch_access_token' do
    before do
      response = double(body: JSON.dump('access_token' => 'access token'))
      allow(subject).to receive(:post).with('oauth2/token', grant_type: :authorization_code, code: 'my-damn-code', redirect_uri: '/my/redirect/url').and_return(response)
    end

    specify do
      access_token = subject.fetch_access_token('my-damn-code', '/my/redirect/url')
      expect(access_token).to eq('access token')
    end
  end
end
