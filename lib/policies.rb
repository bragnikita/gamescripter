class ActionRight

  def ensure
    unless can_do?
      raise 'You have not enough permissions for that action'
    end
  end

  def can_do?
    raise 'Not implemented yet'
  end
end

class RootAdminAction < ActionRight

  def initialize(user)
    @user = user
  end

  def can_do?
    @user[:username] == 'admin'
  end
end

module Permissions
  USER_CREATE = "USER_CREATE"
  USER_CHANGE_META = "USER_CHANGE_META"
  USER_CHANGE_STATUS = "USER_CHANGE_STATUS"
  USER_DELETE = "USER_DELETE"
  USERS_LIST = 'USER_LIST'
end

class CategoryPermissionControl

  def ensure(action)
    false
  end
end
class UsersPermissionControl

  def initialize(user)
    @user = user
  end

  def ensure(action, target_user = nil)
    raise "Has no enogh permissions for action #{action}" unless can_do?(action, target_user)
  end

  def can_do?(action, target_user = nil)
    return true if is_admin?

    if [Permissions::USER_CREATE,
        Permissions::USER_CHANGE_STATUS,
        Permissions::USER_DELETE,
        Permissions::USERS_LIST
    ].include? action
      return is_admin?
    end
    if Permissions::USER_CHANGE_META == action
      return target_user['_id'] == @user['_id'] if target_user
    end
  end

  def visible_parameters(target_user_id)
    if target_user_id == @user['id'] || is_admin?
      return :all
    end
    [:id, :username, :notes, :created_at, :avatar_uri, :display_name, :meta]
  end

  def is_admin?
    @user[:username] == 'admin'
  end
end