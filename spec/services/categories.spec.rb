require 'spec_helper'
require 'categories_service.rb'
require 'mongoid'
require 'mongoid/errors/document_not_found'


describe CategoriesService, :clear => [:categories] do
  let!(:cat) {
    root = Category.create({ title: 'root' })
    parent = Category.create({ title: 'parent', parent: root })
    Category.create([
                      { title: 'category1', parent: parent, meta: { type: 'event'} },
                      { title: 'category2', parent: parent }
                    ])
    parent

  }
  let(:service) {
    CategoriesService.new
  }

  describe '#get' do
    it 'returns category by id' do
      json = HashWithIndifferentAccess.new service.get(cat.id)
      expect(json).to include(:title, :children => have(2).items)
    end
  end

  describe '#get_parents' do
    let(:child) { Category.find_by(title: 'category1') }
    it 'returns parents' do
      json = service.get_parents(child.id)
      expect(json).to be_kind_of(Array)
      expect(json.map { |j| j['title'] }).to eq(['parent', 'root'])
    end
  end

  describe '#create' do
    describe 'when new category is creating' do
      let(:new_cat_attributes) { { title: 'new_category', parent: cat.id } }
      it 'creates new child of parent' do
        new_category = service.create(new_cat_attributes)
        expect(new_category).to be_valid
        expect(new_category.id).not_to be_nil
        expect(new_category.parent.title).to eq('parent')
      end
    end
    describe 'when parent is not exists' do
      it 'raises an exception' do
        expect { service.create({ title: 'new', parent: 'someid' }) }.to \
          raise_error(ObjectNotFound, 'Parent is not found')
      end
    end
  end

  describe '#update' do
    let(:id_to_update) { cat.children[0] }
    let(:attrs) { { title: '@updated@', meta: { :type => 'event', :event => 'Azalia' } } }
    it 'updates successfully' do
      result = service.update(id_to_update, attrs)
      expect(result).to be_truthy
    end
    it 'has attributes updated' do
      service.update(id_to_update, attrs)
      doc = Category.find(id_to_update)
      expect(doc.title).to eq('@updated@')
      expect(doc.meta[:event]).to eq('Azalia')
      expect(doc.meta[:type]).to eq('event')
    end
  end

  describe '#delete' do
    describe 'when there are no subcategories' do
      let(:id_to_destroy) { cat.children[0].id }
      it 'destroys the category' do
        result = service.delete(id_to_destroy)
        expect(result).to be_truthy
      end
    end
    describe 'when there are subcategories' do
      let(:id_to_destroy) { cat.id }
      it 'prevent destroying with an exception' do
        expect { service.delete(id_to_destroy) }.to \
            raise_error Mongoid::Errors::DeleteRestriction
      end
    end
  end

  describe '#all' do
    it('selects all'){ expect(service.all).to have(4).items }
  end
end