# frozen_string_literal: true

require 'spec_helper'
require 'database.rb'

describe DBResourceApiBase, :clear => ['dbtest'] do
  let(:db) { DBResourceApiBase.new(database, 'dbtest') }
  let(:client) { database.client[:dbtest] }

  describe 'create entity' do
    let(:new_entity) { { title: 'New entity', nested: [{ subobject: 'subobject' }] } }
    before(:each) do
      @id = db.create(new_entity)
    end
    it 'returns id' do
      expect(@id).not_to be_nil
      expect(@id).to be_kind_of(String)
    end
    it 'creates object' do
      o = client.find({ _id: BSON::ObjectId.from_string(@id) }).first
      expect(o).not_to be_nil
      expect(o[:_id].to_s).to eq(@id)
      expect(o[:title]).to eq('New entity')
      expect(o[:nested]).to have_exactly(1).item
    end
  end

  describe 'find entities' do
    before do
      [{ title: 'entity1' }, { title: 'entity2' }, { title: 'entity3' }].each do |e|
        db.create(e)
      end
    end
    describe 'find all' do
      it 'returns 3 items' do
        expect(db.filter).to have(3).items
      end
    end
    describe 'find by title' do
      let(:e) { db.filter({ title: 'entity2' }) }
      it 'returns 1 item' do
        expect(e).to have(1).item
      end
      it 'returns item with title = entity2' do
        expect(e[0]).to include(title: 'entity2')
      end
    end
    describe 'find one by title' do
      let(:e) { db.find_one_by(title: 'entity2') }
      it 'returns item with title = entity2' do
        expect(e).to include(title: 'entity2')
      end
    end
  end
end

describe "user's db operations", :clear => ['users'] do
  let(:db) { DBOperations.new(database) }

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
      database.users.insert_many([
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