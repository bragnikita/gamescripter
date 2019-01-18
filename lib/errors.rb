class ClientError < StandardError

end
class ObjectNotFound < ClientError; end
class BadRequest < ClientError; end