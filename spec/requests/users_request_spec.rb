require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'POST /register_changes' do
    let(:user) { create(:user) }
    let(:user_params) do
      {
        user: {
          id: user.id,
          old: {
            "_id": user.id,
            "name": 'Bruce Norries',
            "address": { "street": 'Some street' }
          },
          new: {
            "_id": user.id,
            "name": 'Bruce Willis',
            "address": { "street": 'Nakatomi Plaza' }
          }
        }
      }
    end

    context 'when the record does not exist' do
      before { post '/register_changes', params: { user: { id: 0 } } }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns empty body' do
        expect(JSON.parse(response.body)).to eq({ 'message' => "Couldn't find User with 'id'=0" })
      end
    end

    context 'when the record exists' do
      before { post '/register_changes', params: user_params }

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'returns empty body' do
        expect(response.body).to be_empty
      end

      it 'should register changes' do
        expect(user.user_changes.as_json).to eq([
                                                  {
                                                    'field' => 'name',
                                                    'old' => 'Bruce Norries',
                                                    'new' => 'Bruce Willis'
                                                  },
                                                  {
                                                    'field' => 'address.street',
                                                    'old' => 'Some street',
                                                    'new' => 'Nakatomi Plaza'
                                                  }
                                                ])
      end
    end
  end

  describe 'GET /list_changes' do
    context 'when the request is invalid' do
      before { get '/list_changes', params: { start_date: '2020-03-00', end_date: '2020-03-31' } }

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'returns a validation failure message' do
        expect(JSON.parse(response.body)).to eq('message' => 'invalid date')
      end
    end

    context 'when the request is valid' do
      let(:user) { create(:user) }
      let!(:uc1) { UserChange.create(user: user, field: 'name', old: 'A', new: 'B', created_at: '2020-03-01 00:00:00') }
      let!(:uc2) { UserChange.create(user: user, field: 'name', old: 'B', new: 'C', created_at: '2020-03-01 00:00:01') }
      let!(:uc3) { UserChange.create(user: user, field: 'name', old: 'C', new: 'D', created_at: '2020-06-01 00:00:00') }

      before { get '/list_changes', params: { start_date: '2020-03-01', end_date: '2020-03-31' } }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the user changes' do
        expect(JSON.parse(response.body)).to eq([{ 'field' => 'name', 'old' => 'A', 'new' => 'C' }])
      end
    end
  end
end
