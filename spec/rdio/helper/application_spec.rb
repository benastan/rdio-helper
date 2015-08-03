require 'spec_helper'

module Rdio
  module Helper
    describe Application do
      include Rack::Test::Methods

      def app; described_class; end

      before { allow(Client).to receive(:new).and_return(client) }
      let(:client) { double }

      describe 'GET /oauth/redirect' do
        let(:client) { double(fetch_authorization_endpoint: 'https://rdio.com/rdio/oauth/endpoint')}

        before { get '/oauth/redirect' }
        specify { expect(client).to have_received(:fetch_authorization_endpoint).with('http://example.org/oauth/callback') }
        specify { expect(last_response.status).to eq(302) }
        specify { expect(last_response['Location']).to eq('https://rdio.com/rdio/oauth/endpoint') }
      end

      describe 'GET /oauth/callback' do
        let(:client) { double(fetch_access_token: '290jfasoifjasdfopa')}

        before { get '/oauth/callback?code=2930jfasodaaf' }
        specify { expect(client).to have_received(:fetch_access_token).with('2930jfasodaaf', 'http://example.org/oauth/callback') }
        specify { expect(last_request.env['rack.session'][:access_token]).to eq('290jfasoifjasdfopa') }
        specify { expect(last_response.status).to eq(302) }
        specify { expect(last_response['Location']).to eq('http://example.org/') }
      end

      describe 'GET /' do
        before { get '/', {}, headers }

        context 'when there is no access token' do
          let(:headers) { {} }
          specify { expect(last_response.status).to eq(302) }
          specify { expect(last_response['Location']).to eq('http://example.org/oauth/redirect') }
        end

        context 'when there is an access token' do
          let(:headers) { { 'rack.session' => { access_token: 'boogers' } } }
          specify { expect(last_response.status).to eq(200) }
          specify { expect(last_response.body).to eq('Greate!') }
        end
      end
    end
  end
end
