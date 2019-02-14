require_relative '../spec_helper'
require 'utils.rb'

describe 'Users API', use_database: true, clear: [:users], auth: 'admin', dblog: true do
  let!(:user) do
    id = database.users.insert_one(
      username: 'admin'
    ).inserted_id
    database.users.find(_id: id).first
  end
  describe 'get' do
    it 'should return one user' do
      get "/users/#{user[:_id]}"

      expect(last_response).to be_ok
      json = get_body
      puts json
      expect(json).to include_json(
                        id: user[:_id].to_s,
                        username: be_a_kind_of(String),
                      )
    end
  end
  describe 'update' do
    it 'should update user' do
      put "/users/#{user[:_id]}/meta", as_json(display_name: 'nikita', active: false)

      expect(last_response).to be_ok
      json = get_body
      puts json
      expect(json).to include_json(
                        id: user[:_id].to_s,
                        username: 'admin',
                        display_name: 'nikita',
                      )
    end
    it 'should update user status and meta' do
      put "/users/#{user[:_id]}/status", as_json(display_name: 'nikita', active: false)

      expect(last_response).to be_ok
      json = get_body
      puts json
      expect(json).to include_json(
                        id: user[:_id].to_s,
                        username: 'admin',
                        display_name: 'nikita',
                        active: false,
                      )
    end
  end
  describe 'if delete user' do
    let!(:user_to_delete) do
      id = database.users.insert_one(
        username: 'nikita'
      ).inserted_id
      database.users.find(_id: id).first
    end
    it 'will delete user' do
      delete "/users/#{user_to_delete[:_id]}"

      expect(last_response).to be_ok
      expect(database.users.find({ _id: user_to_delete[:_id] }).count).to be_zero
    end
  end
end