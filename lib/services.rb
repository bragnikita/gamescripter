require 'policies.rb'

class UsersService

  def initialize(executor, db_operations)
    @user = executor
    @db = db_operations
    @permissions = UsersPermissionControl.new(@user);
  end

  def create(params)
    @permissions.ensure(Permissions::USER_CREATE)
    ensure_unique({ username: params[:username] })
    params[:password_digest] = password_hash(params[:password])
    params.delete(:password)
    id = @db.user_create(params)
    serialize(@db.user_one(id))
  end

  def change_meta(id, params)
    @permissions.ensure(Permissions::USER_CHANGE_META, id)

    allowed_parameters = filter(params,
                                :display_name, :notes, :avatar_uri, :meta)
    if params.has_key?(:password)
      allowed_parameters[:password_digest] = password_hash(params[:password])
    end
    @db.user_update(id, allowed_parameters)
    serialize @db.user_one(id)
  end

  def change_status(id, params)
    @permissions.ensure(Permissions::USER_CHANGE_STATUS, id)

    ensure_unique(username: params[:username])
    change_meta(id, params)
    @db.user_update(id, filter(params, :username, :active))
    serialize @db.user_one(id)
  end

  def show(id)
    public_params = @permissions.visible_parameters(id)
    o = serialize(@db.user_one(id))
    filtered = filter(o, *public_params)
    filtered[:id] = o[:id]
    filtered
  end

  def delete(id)
    @permissions.ensure(Permissions::USER_DELETE)
    @db.user_remove(id)
  end

  def list(filter = {})
    # TODO
    @db.user_all.map(&method(:serialize))
  end

  def serialize(user)
    user[:id] = user.delete('_id')
    user.delete('password_digest')
    user
  end

  def ensure_unique(filter, msg = 'Non unique param')
    if @db.user_check_uniques(filter).count > 0
      raise msg;
    end
  end
end

class AuthService

  def initialize(dbops)
    @dao = dbops
  end

  def authenticate(token)
    decoded = JsonWebToken.decode(token)
    raise 'Wrong token' unless decoded

    user_id = decoded['user_id']
    @dao.user_one(user_id)
  end

  def signin(username:, password:)
    user = @dao.user_by_name(username)
    raise AuthError, 'User not found', 402 unless user

    hash = password_hash(password)
    unless user[:password_digest] == hash
      raise AuthError, 'Wrong password', 402
    end

    JsonWebToken.encode({
      user_id: user[:_id]
                        })

  end



end

def password_hash(password)
  Digest::MD5.hexdigest(password)
end

def filter(params_hash = {}, *allowed_keys)
  res = {}
  allowed_keys.each do |key|
    if params_hash.has_key?(key)
      res[key] = params_hash[key]
    end
  end
  res
end