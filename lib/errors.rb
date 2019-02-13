class ClientError < StandardError

end
class ObjectNotFound < ClientError; end
class BadRequest < ClientError; end
class AuthError < ClientError
  def initialize(msg, code = 401)
    super(msg)
    @code = code
  end
end