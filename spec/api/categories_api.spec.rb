require_relative '../spec_helper'
require 'utils.rb'
require_relative 'shared'

describe 'Categories API', clear: ['categories'], auth: 'admin' do
  before(:all) do
    unless User.where(username: 'admin').exists?
      User.my_create!(username: 'admin', active: true, password: 'admin123')
    end
  end
  let!(:root) { Category.create({ title: 'root' }) }
  let!(:parent) { Category.create({ title: 'parent', parent: root, index: 1 }) }
  let!(:cats) {
    Category.create([
                      { title: 'category1', parent: parent, meta: { type: 'event'} },
                      { title: 'category2', parent: parent }
                    ])

  }

  describe '/category/:id/parents' do
    let!(:response) { get "/category/#{cats[0].id}/parents"; get_body }

    it_behaves_like 'successfull json request'
    it 'returns parent categories (root and parent)' do
      expect(last_response.status).to eq(200)
      expect(response).to have(2).items
      expect(response).to all(include(:id, :title))
    end
  end

  describe '/category/:id' do
    let!(:response) { get "/category/#{parent.id}"; get_body }

    it_behaves_like 'successfull json request'
    it 'returns parent and children categories' do
      expect(last_response.status).to eq(200)
      expect(response).to include_json(
                            id: parent.id.to_s,
                            title: parent.title,
                            parent_id: root.id.to_s,
                            index: 1,
                            children: all(include(:id, :title))
                          )
    end
  end
  
  describe '/categories/root' do
    before { get '/categories/root' }

    it_behaves_like 'successfull json request'
    it 'returns root' do
      expect(get_body).to have(1).item
      expect(get_body[0]).to include_json(id: root.id.to_s, title: root.title)
    end
  end

  describe '/categories' do
    before { get '/categories' }

    it_behaves_like 'successfull json request'
    it 'returns list of all categories' do
      expect(get_body).to have(4).items
      expect(get_body).to all(include(:id, :title))
    end
  end

  describe 'put /categories' do
    before { put '/categories', as_json(title: 'new category', index: 3, parent_id: parent.id.to_s) }
    let(:created_id) { get_body[:id] }

    it_behaves_like 'successfull json request'
    it 'creates new category under parent' do
      expect(get_body).to include(:id => anything, :title => 'new category')
      expect(get_body[:parent_id]).to eq(parent.id.to_s)
    end
  end

  describe 'post /category/:id' do
    let(:target_id) { cats[0].id.to_s }
    before(:each) { post "/category/#{target_id}", as_json(:title => 'new_value', :parent_id => root.id.to_s) }

    it_behaves_like 'successfull request'
    it 'updates the category' do
      c = Category.find(target_id)
      expect(c.title).to eq('new_value')
      expect(c.parent_id).to eq(root.id)
    end
  end
end