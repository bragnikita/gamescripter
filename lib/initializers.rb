require 'mongoid'

module Gamescripter
  module Extensions
    module Document
      def as_json(options = {})
        attrs = super(options)
        if attrs["_id"]
          attrs["id"] = attrs["_id"].to_s
          attrs.delete("_id")
        end
        attrs.each_key do |key|
          val = attrs[key]
          if val.instance_of?(BSON::ObjectId)
            attrs[key] = val.to_s
          end
        end
        attrs
      end

    end
  end
end
Mongoid::Document.__send__(:include, Gamescripter::Extensions::Document)
#
# This core extension customizes XML and JSON serialization in Mongoid::Document
# objects:
#   * Serializes BSON::ObjectIDs as strings in XML
#   * Removes leading underscores from attributes (such as _id, _type)
#   * Allows documents to customize serialization even further declaring a
#     `serialize_attributes!` method, e.g.:
#       def serialize_attributes!(attribute_hash)
#         attribute_hash.delete(:unnecessary_key)
#         attribute_hash[:password] = ''
#       end
#
# It also adds support for serialization to Mongoid::Criteria objects.  This is
# especially helpful when used with `respond_with`:
#
#   def index
#     @categories = Category.asc(:name)
#     respond_with(@categories)
#   end
#
require 'active_model'

module Mongoid
  module Components
    def self.included(base)
      base.class_eval do
        include Mongoid::Serialization::JSON
      end
    end
  end
end


module Mongoid
  module Serialization

    # Returns a new hash with leading underscores removed from key names
    def Serialization.clean_hash_keys(h)
      h.inject({}) do |h, (k, v)|
        # TODO: This converts symbols to strings unnecessarily
        h[k.to_s =~ /^_/ ? k.to_s.gsub(/^_+/, '') : k] = v
        h
      end
    end

    module JSON
      def as_json(*options)
        Serialization.clean_hash_keys(super).tap do |h|
          self.serialize_attributes!(h) if self.respond_to?(:serialize_attributes!)
        end
      end
    end

  end

end


class Mongoid::Criteria
  def as_json(options = nil)
    map { |v| v.as_json(options) }
  end

  def to_xml(options = {}, &block)
    options = options.dup
    options[:root] ||= ActiveSupport::Inflector.pluralize(ActiveSupport::Inflector.underscore(klass)).tr('/', '_')
    entries.to_xml(options, &block)
  end
end
