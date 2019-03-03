# frozen_string_literal: true

require 'spec_helper'
require 'services.rb'
require 'database.rb'

describe 'UsersService', clear: ['users'] do
  let(:executor) do
    { username: 'admin' }
  end
  let(:service) do
    UsersService.new(executor)
  end
  let!(:single_user) do
    User.my_create!(username: 'nikita', password: 'somepass', active: true, display_name: 'Nikita')
  end
  let!(:admin) do
    User.my_create!(username: 'admin', password: 'somepass', active: true, display_name: 'Admin')
  end
  describe 'Create user' do
    let(:result) do
      service.create(
        username: 'new_user',
        password: 'new_password'
      )
    end
    describe 'when username is unique' do
      it 'returns new user' do
        expect(result).to be_truthy
        expect(result).to be_valid
        expect(result).not_to respond_to(:password)
        expect(result.username).to eq('new_user')
        expect(result.password_digest).not_to be_nil
      end
    end
    describe 'when duplicate username' do
      let(:dup_user) do
        service.create(username: result.username, password: 'new_passs')
      end
      it 'should rise an exception' do
        expect { dup_user.id }.to raise_error StandardError, 'username is already in use'
      end
    end
  end

  describe 'Update user', clear: ['users'] do
    describe 'update meta' do
      let(:prev_user) do
        {
          username: 'nikita',
          notes: 'what I like doing',
          password: 'old_pass'
        }
      end
      let!(:user_id) do
        User.my_create!(prev_user).id
      end
      it 'will change users notes' do
        res = service.change_meta(user_id,
                                  notes: 'I like swimming',
                                  password: 'New password')
        expect(res).to be_truthy
        updated = User.find(user_id)
        expect(updated.notes).to eq('I like swimming')
      end
    end
    describe 'update status' do
      let(:prev_user) do
        {
          username: 'nikita',
          active: true
        }
      end
      let!(:user_id) do
        User.my_create!(prev_user)
      end
      it 'will change users notes' do
        res = service.change_status(user_id,
                                    active: false)
        expect(res).to be_truthy
        updated_db = User.find(user_id)
        expect(updated_db.active).to eq(false)
      end
    end
  end

  describe '#show' do
    describe '#when admin' do
      it 'selects all attributes' do
        expect(as_hash service.show(single_user.id)).to \
           include(:username, :active, :notes, :created_at)
      end
    end
    describe '#when other user' do
      let(:executor) { {username: 'nikita'}}
      it 'selects basic attrs only' do
        user = as_hash service.show(admin.id)
        expect(user).to \
           include(:username, :notes, :display_name)
        expect(user).not_to \
           include(:active)
      end
    end
  end

  describe '#list' do
    it 'selects all' do
      expect(service.list).to have(2).items
      expect(service.list).to all(include('id', 'username'))
    end
    it 'selects active only' do
      expect(service.list({active: true})).to have(2).items
    end
    it 'selects admin only' do
      expect(service.list({username: 'admin'})).to have(1).item.and \
        all(include('username' => 'admin'))
    end
  end


end