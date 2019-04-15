require_relative '../spec_helper'
require 'utils.rb'
require_relative 'shared'


describe 'Scripts API', auth: 'admin' do
  content = 'Name: serif *emotion*'

  before(:all) {
    recreate_db
    @root = Category.where(title: 'root').first
    @root_id = @root.id.to_s
  }


  describe 'POST /scripts' do
    before(:all) { auth; post '/scripts', as_json(category_id: @root_id, title: 'chapter 1', source: content) }
    let(:body) { get_body }

    it_behaves_like 'successfull json request'
    it 'returns new script' do
      expect(body).to include_json(
                        :id => be_truthy,
                        :title => 'chapter 1',
                        :source => content,
                        :category_id => @root_id
                      )
    end
  end

  describe 'PUT /script/:id' do
    before(:all) {
      @sample_script = Script.create!(category: @root, title: 'chapter 2', source: content)
      @sample_script_id = @sample_script.id.to_s
    }
    let(:sample_script) { Script.find(@sample_script_id) }
    before(:all) { auth; put "/script/#{@sample_script_id}", as_json(title: 'chapter 22') }
    it_behaves_like 'successfull request'
    it 'updates script title' do
      expect(sample_script.title).to eq('chapter 22')
    end
  end
  describe 'PUT /script/:id/content/save' do
    before(:all) {
      @sample_script = Script.create!(category: @root, title: 'chapter 3', source: content)
      @sample_script_id = @sample_script.id.to_s
    }
    let(:sample_script) { Script.find(@sample_script_id) }
    before(:all) { auth; put "/script/#{@sample_script_id}/content/save", 'basically new content' }
    it_behaves_like 'successfull request'
    it 'updates script content' do
      expect(sample_script.source).to eq('basically new content')
      expect(sample_script.html).to be_nil
    end
  end
  describe 'PUT /script/:id/content/update' do
    before(:all) {
      @sample_script = Script.create!(category: @root, title: 'chapter 4', source: content)
      @sample_script_id = @sample_script.id.to_s
    }
    let(:sample_script) { Script.find(@sample_script_id) }
    before(:all) { auth; put "/script/#{@sample_script_id}/content/update", 'basically new content' }
    it_behaves_like 'successfull request'
    it 'updates script content and html' do
      expect(sample_script.source).to eq('basically new content')
      expect(sample_script.html).to be_truthy
    end
  end
  describe 'GET /script/:id/preview' do
    before(:all) {
      @sample_script = Script.create!(category: @root, title: 'chapter 5')
      @sample_script_id = @sample_script.id.to_s
      ScriptOperations.new.update_content(@sample_script_id, content)
    }
    let(:sample_script) { Script.find(@sample_script_id) }
    before(:all) { auth; get "/script/#{@sample_script_id}/preview" }
    it_behaves_like 'successfull request'
    it 'returns html response' do
      expect(last_response.body).to include('emotion')
      expect(last_response.headers['Content-Type']).to include('html')
    end
  end

  describe 'GET /script/:id', :print => true do
    before(:all) {
      @sample_script = Script.create!(category: @root, title: 'chapter 6', source: content, html: 'html')
      @sample_script_id = @sample_script.id.to_s
    }
    let(:sample_script) { Script.find(@sample_script_id) }
    before(:all) { auth; get "/script/#{@sample_script_id}" }
    it_behaves_like 'successfull json request'
    it 'returns script data without html' do
      expect(get_body).to include(
                            :title => 'chapter 6',
                            :source => content,
                          )
      expect(get_body).not_to include(:html)
    end
  end

end