require 'mongo'
require 'singleton'

class Database
  include Singleton

  APP_COLLECTIONS = %w(categories users scripts)

  def initialize
    # TODO try to load hostname and other parameters from config
  end

  def connect(host = '127.0.0.1:27017',
              database = 'gamescripter',
              username = 'gamescripter-api',
              password = 'initial_password')
    @client = Mongo::Client.new([host],
                                auth_source: database,
                                database: database,
                                user: username,
                                password: password,
                                max_pool_size: 15,
    )
    ensure_database
  end

  def client
    @client
  end

  def categories
    @client[:categories]
  end

  def scripts
    @client[:scripts]
  end

  def next_key_for(sequence_or_coll)

    seq_name = if sequence_or_coll.is_a? Mongo::Collection
                 sequence_or_coll.name
               else
                 sequence_or_coll
               end
    seq_key = @client[:sequences].find_one_and_update(
      {name: seq_name},
      "$inc" => {next_val: 1}
    )
    seq_key[:next_val]
  end

  private

  def ensure_database
    APP_COLLECTIONS.each do |coll_name|
      if @client[:sequences].find(name: coll_name).count == 0
        @client[:sequences].insert_one(name: coll_name, next_val: 1)
      end
    end
    if @client[:categories].indexes.get({parent_id: 1}).nil?
      @client[:categories].indexes.create_one({parent_id: 1})
    end
  end
end