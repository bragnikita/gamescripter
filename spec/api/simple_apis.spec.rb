require_relative '../spec_helper'
require 'utils.rb'
require_relative 'shared'
require 'json'

describe 'Dictionaries API', auth: 'admin' do
  describe 'GET /dictionaries' do
    before(:all) do
      get '/dictionaries'
    end
    it_behaves_like 'successfull json request'
    it 'returns at least 3 dictionaries' do
      expect(get_body).to have(3).items
    end
    it 'has all paramerters' do
      expect(get_body).to all(include(:name, :title, :records))
      expect(get_body[0][:records]).to all(include(:parameter, :title, :index))
    end
  end
end