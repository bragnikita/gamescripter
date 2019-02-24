require 'spec_helper'
require 'scripts_service.rb'
require 'mongoid'
require 'mongoid/errors/document_not_found'


describe ScriptOperations, :clear => [:scripts] do
  let(:service) { ScriptOperations.new }
  before(:all) do
    unless Category.where(title: 'root').exists?
      @root = Category.create!({ title: 'root' })
    else
      @root = Category.where(title: 'root').first
    end
  end
  let(:script) do
    service.create(title: 'script 1', version: 'v0.1', category: @root,
                   source: 'some source', html: '<div/>')
  end
  describe '#create' do
    let(:new_script) do
      service.create(title: 'script 1', version: '0.1', category: @root)
    end

    it 'will create new script' do
      expect(new_script.id).not_to be_nil
      expect(new_script.title).to eq('script 1')
    end
  end

  describe '#get_params' do
    let(:result) { service.get_params(script.id) }
    it 'returns script without source and html fields' do
      expect(result.title).to eq('script 1')
      expect(result.has_attribute?(:source)).to be_falsey
      expect(result.has_attribute?(:html)).to be_falsey
    end
  end

  describe '#save_content' do
    before do
      service.save_content(script.id, 'source content')
    end
    it 'have script source updated' do
      expect(Script.find(script.id).source).to eq('source content')
    end
  end

  describe '#update_content' do
    let(:result) { service.update_content(script.id, load_fixture('source_script_1.txt')) }
    let(:reloaded) { Script.find(script.id) }
    it 'finishes without exceptions' do
      expect { result }.not_to raise_exception
    end
    it 'have source updated' do
      expect(result).to be_truthy
      expect(reloaded.source).to start_with('[ гостиная ]')
      expect(reloaded.html).not_to be_nil
      expect(reloaded.html.length).to be > 100
      p reloaded.html
    end
  end
end

def load_fixture(path)
  File.read(File.expand_path "fixtures/#{path}", __dir__)
end