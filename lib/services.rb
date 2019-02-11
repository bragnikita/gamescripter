require 'policies.rb'

class UsersService

  def initialize(executor, db_operations)
    @user = executor
    @db = db_operations
  end

  def create(params)
    UsersPermissionControl.new(@user).ensure(Permissions::USER_CREATE)
    ensure_unique({ username: params[:username] })
    params[:password_digest] = password_hash(params[:password])
    params.delete(:password)
    id = @db.user_create(params)
    serialize(@db.user_one(id))
  end

  def change_meta(id, params)
    UsersPermissionControl.new(@user).ensure(Permissions::USER_CHANGE_META, id)

    allowed_parameters = filter(params,
                                :display_name, :notes, :avatar_uri, :meta)
    if params.has_key?[:password]
      allowed_parameters[:password_digest] = password_hash(params[:password])
    end
    @db.user_update(id, allowed_parameters)
  end

  def change_status(id, params)
    UsersPermissionControl.new(@user).ensure(Permissions::USER_CHANGE_STATUS, id)

    ensure_unique(username: params[:username])
    change_meta(id, params)
    @db.user_update(id, filter(params, :username, :active))
  end

  def show(id)
    public_params = UsersPermissionControl.new(@user).visible_parameters(id)
    o = serialize(@db.user_one(id))
    filtered = filter(o, *public_params)
    filtered[:id] = o[:id]
    filtered
  end

  def serialize(user)
    user[:id] = user.delete('_id')
    user.delete('password_digest')
    user
  end

  def password_hash(password)
    Digest::MD5.hexdigest(password)
  end

  def filter(params_hash = {}, *allowed_keys)
    res = {}
    allowed_keys.each do |key|
      if params_hash.has_key?(key) {
        res[key] = params_hash[key]
      }
      end
    end
    res
  end

  def ensure_unique(filter, msg = 'Non unique param')
    if @db.user_check_uniques(filter).count > 0
      raise msg;
    end
  end
end