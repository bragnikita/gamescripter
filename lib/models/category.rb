require 'mongoid'

class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :index, type: Numeric
  belongs_to :parent, class_name: 'Category', inverse_of: :parent, optional: true
  has_many :children, class_name: 'Category', inverse_of: :parent, dependent: :restrict_with_exception
  has_many :scripts, class_name: 'Script', inverse_of: :category, dependent: :restrict_with_exception

  field :meta, type: Hash, default: {}
end