require 'spec_helper'

module Rdio
  module Helper
    describe GroupActivityStreamByWeek do
      let(:client) { Client.new(access_token: ENV['RDIO_ACCESS_TOKEN']) }

      let(:current_user) { client.get_current_user }
      let(:activity_stream) do
        {
          'updates' => [
            {
              'date' => '2015-08-05T19:00:25',
              'updates' => [ 'boogers' ]
            },
            {
              'date' => '2015-08-06T15:00:25',
              'updates' => [ 'spitoon' ]
            },
            {
              'date' => '2015-07-23T19:00:25',
              'updates' => [ 'loogy' ]
            }
          ]
        }
      end

      before { allow(client).to receive(:get_activity_stream).with(user: current_user['key']).and_return(activity_stream) }

      subject { described_class.call(client: client, user: current_user) }

      specify do
        expect(subject.updates_by_week).to eq(
          {
            29 => [
              {
                'date' => '2015-07-23T19:00:25',
                'updates' => [ 'loogy' ]
              }
            ],
            31 => [
              {
                'date' => '2015-08-05T19:00:25',
                'updates' => [ 'boogers' ]
              },
              {
                'date' => '2015-08-06T15:00:25',
                'updates' => [ 'spitoon' ]
              }
            ]
          }
        )
      end
    end
  end
end
