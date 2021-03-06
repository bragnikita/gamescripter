require_relative 'policies.rb'
require_relative 'utils.rb'
require_relative 'models/user'
require_relative 'models/dictionary'

class UsersService

  def initialize(executor)
    @user = executor
    @permissions = UsersPermissionControl.new(@user);
  end

  def create(params)
    @permissions.ensure(Permissions::USER_CREATE)
    raise 'username is already in use' if User.where(username: params[:username]).exists?
    password = params[:password]
    raise 'password is required' unless password
    params[:password_digest] = FormatUtils::password_hash(password)
    params.delete(:password)
    User.create!(params)
  end

  def change_meta(id, params)
    @permissions.ensure(Permissions::USER_CHANGE_META, id)

    allowed_parameters = filter(params,
                                :display_name, :notes, :avatar_uri, :meta)
    if params.has_key?(:password)
      allowed_parameters[:password_digest] = FormatUtils::password_hash(params[:password])
    end
    allowed_parameters.delete(:password)
    User.find(id).update_attributes!(allowed_parameters)
  end

  def change_status(id, params)
    @permissions.ensure(Permissions::USER_CHANGE_STATUS, id)

    raise 'username is already in use' if User.where(username: params[:username]).exists?
    change_meta(id, params)
    User.find(id).update_attributes!(filter(params, :username, :active))
  end

  def show(id)
    public_params = @permissions.visible_parameters(id)
    if public_params == :all
      filter = {}
    else
      filter = { only: public_params }
    end
    User.find(id).as_json(filter)
  end

  def delete(id)
    @permissions.ensure(Permissions::USER_DELETE)
    User.find(id).destroy
  end

  def list(filter = {}, sort = { username: 'asc' })
    @permissions.ensure(Permissions::USERS_LIST)
    User.where(filter).order_by(sort).map(&:as_json)
  end

end

class AuthService

  def authenticate(token)
    decoded = JsonWebToken.decode(token)
    raise AuthError.new('Wrong token', 401) unless decoded

    user_id = decoded['user_id']
    user = User.where(id: user_id).first
    raise AuthError.new('User was deleted', 404) if user.nil?
    user
  end

  def signin(username:, password:)
    user = User.where(username: username).first
    raise AuthError.new('User not found', 400) unless user

    unless user.is_password_valid? password
      raise AuthError.new('Wrong password', 400)
    end

    JsonWebToken.encode({
                          user_id: user.id.to_s
                        })
  end
end

class DictionariesService

  def load_all
    json = []
    Dictionary.all.each do |dict|
      json << {
        id: dict.id.to_s,
        name: dict.name,
        title: dict.title,
        records: dict.records.map { |r| r.as_json }
      }
    end
    json
  end

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