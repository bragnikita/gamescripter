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
      post '/auth/create', as_json(username: 'admin', password: 'admin123')

      expect(last_response).to be_ok
      token = get_body[:token]
      expect(token).not_to be_nil
      decoded_header = JsonWebToken.decode(token)
      expect(decoded_header).not_to be_nil
      expect(decoded_header['user_id']).to eq(user[:_id].to_s)
    end
  end
  describe 'If authorization succeeded', use_database: true, clear: ['users'] do
    before do
      post '/auth/create', as_json(username: user[:username], password: 'admin123')
      @token = get_body[:token]
    end
    it "will get request user's info" do
      header('Authorization', 'Bearer ' + @token)
      get "/users/#{user[:_id]}"

      expect(last_response).to be_ok
      expect(get_body[:username]).to eq(user[:username])
    end
  end
end

describe 'If authorization failed' do
  it "will get request user's info" do
    header('Authorization', 'Bearer ' + '<<<undecodable token>>>')
    get "/users/0"

    expect(last_response).not_to be_ok
    expect(last_response.status).to eq(422)
  end
end