require 'spec_helper'

describe Rdio::Helper::Client do
  let(:access_token) { ENV['RDIO_ACCESS_TOKEN'] }

  subject do
    options = {}
    options[:access_token] = access_token if access_token
    described_class.new(options)
  end

  describe '#fetch_authorization_endpoint' do
    let(:access_token) { nil }

    specify do
      authorization_endpoint = subject.fetch_authorization_endpoint('http://example.com/redirect')
      expect(authorization_endpoint).to include ENV['RDIO_CLIENT_ID']
    end
  end

  describe '#fetch_access_token' do
    let(:access_token) { nil }

    before do
      response = double(body: JSON.dump('access_token' => 'access token'))
      allow(subject).to receive(:post).with('oauth2/token', grant_type: :authorization_code, code: 'my-damn-code', redirect_uri: '/my/redirect/url').and_return(response)
    end

    specify do
      access_token = subject.fetch_access_token('my-damn-code', '/my/redirect/url')
      expect(access_token).to eq('access token')
    end
  end

  describe '#get_favorites' do
    specify do
      favorites = subject.get_favorites
      expect(favorites.count).to_not eq 0
    end
  end

  describe '#get_current_user' do
    specify do
      current_user = subject.get_current_user
      expect(current_user.count).to_not eq 0
    end
  end

  describe '#get_activity_stream' do
    let(:current_user) { subject.get_current_user }

    specify do
      activity_stream = subject.get_activity_stream(user: current_user['key'])
      expect(activity_stream.count).to_not eq 0
    end
  end
end
