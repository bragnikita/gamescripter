require_relative '../spec_helper'

describe 'Users API', use_database: true, clear: [:users], auth: 'admin' do
  let!(:user) do
    id = database.users.insert_one({
                             username: 'admin'
                           }).inserted_id
    database.users.find({_id: id}).first
  end

  it "should return one user" do
    get "/users/#{user[:_id]}"

    expect(last_response).to be_ok
  end
end