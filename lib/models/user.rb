require 'mongoid'

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, type: String
  field :password_digest, type: String
  field :active, type: Boolean, default: true

  field :display_name, type: String
  field :notes, type: String
  field :avatar_uri, type: String

  field :meta, type: Hash, default: {}

  def self.my_create!(params)
    p = params.dup
    unless p[:password_digest]
      password = p[:password]
      if password
        p[:password_digest] = User.make_password_digest password
      end
    end
    p.delete(:password)
    User.create!(p)
  end

  def self.make_password_digest(password)
    FormatUtils::password_hash(password)
  end

  def is_password_valid?(password)
    self.password_digest == User.make_password_digest(password)
  end

end