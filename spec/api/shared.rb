RSpec.shared_examples 'successfull json request' do
  it 'responds with ok code' do
    expect(last_response.status).to be <= 400
  end
  it 'has valid json content' do
    expect(get_body).not_to be_nil
  end
end
RSpec.shared_examples 'successfull request' do
  it 'responds with ok code' do
    expect(last_response.status).to be <= 400
  end
end