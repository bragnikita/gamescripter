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

class DBOperations

  def initialize(db)
    @database = db
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
    db.users.find(_id: db.mongo_id(id)).limit(1).first
  end

  def user_all
    db.users.find
  end

  def user_by_name(username)
    db.users.find({username: username}).first
  end

  def user_remove(id)
    db.users.delete_one({ _id: db.mongo_id(id) })
  end

  def user_check_uniques(filter = {})
    db.users.find(filter)
  end

  private


end