require_relative '../spec_helper'
require 'utils.rb'

describe 'Auth API', use_database: true, clear: ['users'] do
  let!(:user) do
    id = database.users.insert_one(
      username: 'admin',
      password_digest: FormatUtils::password_hash('admin123'),
      active: true,
    ).inserted_id
    database.users.find(_id: id).first
  end
  describe 'signin' do
    it 'should authenticate user by login and password' do
      post '/auth', as_json(username: 'admin', password: 'admin123')

      expect(last_response).to be_ok
      token = get_body[:token]
      expect(token).not_to be_nil
      decoded_header = JsonWebToken.decode(token)
      expect(decoded_header).not_to be_nil
      expect(decoded_header['user_id']).to eq(user[:_id].to_s)
    end
  end

  describe 'token authentication' do
    before do

    end
  end
end