# frozen_string_literal: true

require 'spec_helper'
require 'database.rb'

Database.instance.connect
DATABASE = Database.instance

describe "user's db operations" do
  let(:db) { DBOperations.new(DATABASE) }
  before(:each) do
    DATABASE.users.delete_many
  end

  describe 'insert user' do
    let(:user) do
      {
        username: 'test',
        active: true,
        meta: {
          vk: 'http://'
        }
      }
    end
    it "returns user's id" do
      id = db.user_create user
      expect(id).to be_truthy
      expect(id).to be_kind_of(BSON::ObjectId)
      expect(id.to_s.length).to eq(24)
    end
  end

  describe 'update user' do
    let(:user) do
      { username: 'test', meta: { vk: 'http://', twitter: 'some' } }
    end
    let!(:id) { db.user_create(user) }
    it 'updates user' do
      db.user_update(
        id,
        displayName: 'nikita',
        meta: { vk: 'http://vk.com', fb: 'http://fb' }
      )
      updated_user = db.user_one(id)
      expect(updated_user['username']).to eq('test')
      expect(updated_user['displayName']).to eq('nikita')
      expect(updated_user['meta']['vk']).to eq('http://vk.com')
      expect(updated_user['meta'][:fb]).to eq('http://fb')
      expect(updated_user['meta'][:twitter]).to be_nil
    end
  end

  describe 'select all' do
    before do
      DATABASE.users.insert_many([
                                   { username: 'nikita' },
                                   { username: 'alex' },
                                   { username: 'ivan' }
                                 ])
    end
    it 'will select 3 users' do
      users = db.user_all
      expect(users).to have(3).items
    end
  end
end