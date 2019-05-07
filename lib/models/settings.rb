require 'mongoid'

class Settings
  include Mongoid::Document

  field :preview, type: Hash, default: {
    css_uri: "/public/assets/preview.css",
  }
end