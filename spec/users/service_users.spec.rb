# frozen_string_literal: true

require 'spec_helper'
require 'services.rb'
require 'database.rb'

describe 'UsersService', clear: ['users'] do
  let(:executor) do
    { username: 'admin' }
  end
  let(:service) do
    UsersService.new(executor, DBOperations.new(database))
  end
  describe 'Create user' do
    let(:result) do
      service.create(
        username: 'new_user',
        password: 'new_password'
      )
    end
    it 'returns new user' do
      expect(result).to be_truthy
      expect(result[:id]).not_to be_nil
      expect(result[:password]).to be_nil
      expect(result[:password_digest]).to be_nil
      expect(result[:_id]).to be_nil
    end

    it 'creates new user', dblog: true do
      saved_user = database.users.find(_id: result[:id]).first
      expect(saved_user).to be_truthy
      expect(saved_user[:password]).to be_nil
      expect(saved_user[:password_digest]).to be_truthy
      expect(saved_user[:username]).to eq('new_user')
    end
  end

  describe 'Update user', clear: ['users'] do
    describe 'update meta' do
      let!(:prev_user) do
        {
          username: 'nikita',
          notes: 'what I like doing',
          password: 'old_pass'
        }
      end
      let!(:user_id) do
        database.users.insert_one(prev_user).inserted_id
      end
      it 'will change users notes' do
        updated = service.change_meta(user_id,
                                      notes: 'I like swimming',
                                      password: 'New password')
        expect(updated[:notes]).to eq('I like swimming')
        updated_db = database.users.find(_id: database.mongo_id(user_id)).first
        expect(updated_db[:notes]).to eq('I like swimming')
      end
    end
    describe 'update status' do
      let!(:prev_user) do
        {
          username: 'nikita',
          active: true
        }
      end
      let!(:user_id) do
        database.users.insert_one(prev_user).inserted_id
      end
      it 'will change users notes' do
        updated = service.change_status(user_id,
                                      active: false)
        expect(updated[:active]).to eq(false)
        updated_db = database.users.find(_id: database.mongo_id(user_id)).first
        expect(updated_db[:active]).to eq(false)
      end
    end
  end


end