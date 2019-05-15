require 'mongoid'
require_relative 'script'

class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :description, type: String
  field :index, type: Numeric
  field :content_type, type: String
  field :subtitle, type: String
  belongs_to :parent, class_name: 'Category', inverse_of: :children, optional: true
  has_many :children, class_name: 'Category', inverse_of: :parent, dependent: :restrict_with_exception
  has_many :scripts, class_name: 'Script', inverse_of: :category, dependent: :restrict_with_exception

  field :meta, type: Hash, default: {}

  validates :title, presence: true, uniqueness: {scope: :parent}
  validates :content_type, presence: true
end