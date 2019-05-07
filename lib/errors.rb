class ClientError < StandardError
  def initialize(msg = '', code = 400)
    super(msg)
    @code = code
  end
  attr_reader :code
end
class ObjectNotFound < ClientError
  def initialize(msg = '')
    super(msg, 404)
  end
end
class BadRequest < ClientError
  def initialize(msg = '')
    super(msg, 400)
  end
end
class AuthError < ClientError
  def initialize(msg = '', code=401)
    super(msg, code)
  end
end

class ScriptProcessingError < ClientError
  def initialize(msg = '', code=422)
    super(msg, code)
  end
end