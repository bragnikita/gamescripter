# frozen_string_literal: true

require 'mongo'
require 'singleton'

DB_HOST = ENV['DB_HOST']
DB_USERNAME = ENV['DB_USERNAME']
DB_PASSWORD = ENV['DB_PASSWORD']
DB_DATABASE = ENV['DB_DATABASE']

class Database
  include Singleton

  APP_COLLECTIONS = %w[categories users scripts permissions].freeze

  def connect(host = DB_HOST,
              database = DB_DATABASE,
              username = DB_USERNAME,
              password = DB_PASSWORD)
    @client = Mongo::Client.new([host],
                                auth_source: database,
                                database: database,
                                user: username,
                                password: password,
                                max_pool_size: 15
    )
    ensure_database
  end

  attr_reader :client

  def categories
    @client[:categories]
  end

  def scripts
    @client[:scripts]
  end

  def users
    @client[:users]
  end

  def permissions
    @client[:permissions]
  end

  def next_key_for(sequence_or_coll)

    seq_name = if sequence_or_coll.is_a? Mongo::Collection
                 sequence_or_coll.name
               else
                 sequence_or_coll
               end
    seq_key = @client[:sequences].find_one_and_update(
      { name: seq_name },
      '$inc' => { next_val: 1 }
    )
    seq_key[:next_val]
  end


  def mongo_id(id)
    return id if id.instance_of?(BSON::ObjectId)

    BSON::ObjectId.from_string(id)
  end

  def current_time()
    DateTime.parse(DateTime.now.to_s)
  end

  private

  def ensure_database
    if @client[:categories].indexes.get(parent_id: 1).nil?
      @client[:categories].indexes.create_one(parent_id: 1)
    end
  end
end

module DbHelpers
  def query(collection)
    if collection.is_a? Mongo::Collection::View
      res = []
      collection.each do |c|
        c[:id] = c[:_id].to_s
        res << c
      end
      res
    else
      collection[:id] = collection[:_id].to_s
      collection
    end
  end
end

class DBResourceApiBase

  include DbHelpers

  attr_accessor :default_sorting

  def initialize(db, collection_name)
    @db = db
    @collection_name = collection_name
    @default_sorting = { created_at: 1 }
  end

  def create(params)
    unless params['created_at']
      params['created_at'] = @db.current_time
    end
    collection.insert_one(params).inserted_id.to_s
  end

  def update(id, params)
    unless params.empty?
      collection.update_one({ _id: @db.mongo_id(id) }, '$set' => params)
    end
  end

  def find_one(id)
    query collection.find(_id: @db.mongo_id(id)).limit(1).first
  end

  def find_one_by(params)
    query collection.find(params).first
  end

  def filter(filter = {}, sort = {})
    coll = collection.find(filter)
    if sort.empty?
      coll = coll.sort(@default_sorting)
    else
      coll = coll.sort(sort)
    end
    query coll
  end

  def delete(id)
    collection.delete_one({ _id: @db.mongo_id(id) })
  end

  def exists?(filter)
    collection.find(filter).count == 0
  end

  def collection
    @db.client[@collection_name]
  end

end


class CategoriesDbApi < DBResourceApiBase
  def initialize(db, collection_name)
    super
  end
end

class DBOperations

  include DbHelpers
  attr_reader :categories

  def initialize(db)
    @database = db
    @categories = CategoriesDbApi.new(db, :categories)
  end

  def db
    @database
  end

  def user_create(params)
    unless params['created_at']
      params['created_at'] = db.current_time
    end
    db.users.insert_one(params).inserted_id
  end

  def user_update(id, params = {})
    unless params.empty?
      db.users.update_one({ _id: db.mongo_id(id) }, '$set' => params)
    end
  end

  def user_one(id)
    query db.users.find(_id: db.mongo_id(id)).limit(1).first
  end

  def user_all
    query db.users.find
  end

  def user_by_name(username)
    query db.users.find({ username: username }).first
  end

  def user_remove(id)
    db.users.delete_one({ _id: db.mongo_id(id) })
  end

  def user_check_uniques(filter = {})
    query db.users.find(filter)
  end

end
