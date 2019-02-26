require 'mongoid'

class Script
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :index, type: Numeric
  field :version, type: String
  field :attachments_path, type: String
  field :meta, type: Hash, default: {}

  embeds_many :images

  field :source, type: String
  field :html, type: String

  belongs_to :category, class_name: 'Category'

  scope :params, -> { without(:source, :html) }
  scope :with_source, -> { without(:html) }

  validates :title, uniqueness: { scope: :category }
end

class Image
  include Mongoid::Document
  embedded_in :script

  field :key, type: String
  field :filename, type: String
end
