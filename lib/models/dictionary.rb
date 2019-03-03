require 'mongoid'

class Dictionary
  include Mongoid::Document

  field :name, type:String
  field :title, type:String
  embeds_many :records, class_name: 'DictRecord'
end

class DictRecord
  include Mongoid::Document
  field :parameter, type: String
  field :title, type: String
  field :index, type: Integer
end