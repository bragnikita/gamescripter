require 'spec_helper'
require 'services.rb'
require 'database.rb'

Database.instance.connect
DATABASE = Database.instance

describe 'Create user' do
  before(:each) do
    DATABASE.users.delete_many
  end
  let(:executor) {
    { username: 'admin' }
  }
  let(:service) {
    UsersService.new(executor, DBOperations.new(DATABASE))
  }
  let(:result) {
    service.create({
                     username: 'new_user',
                     password: 'new_password',
                   })
  }
  it 'returns new user' do
    expect(result).to be_truthy
    expect(result[:id]).not_to be_nil
    expect(result[:password]).to be_nil
    expect(result[:password_digest]).to be_nil
    expect(result[:_id]).to be_nil
  end

  it 'creates new user' do
    saved_user = DATABASE.users.find({_id: result[:id]}).first
    expect(saved_user).to be_truthy
    expect(saved_user[:password]).to be_nil
    expect(saved_user[:password_digest]).to be_truthy
    expect(saved_user[:username]).to eq('new_user')
  end
end