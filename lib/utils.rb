require 'jwt'

module ApiHelpers
  def parse_body
    request.body.rewind
    JSON.parse(request.body.read, symbolize_names: true)
  end

  def set_jwt_cookie(jwt_payload)
    response.set_cookie(
      :access_token,
      value: jwt_payload,
      expires: Time.now + 3600*24,
      secure: ENV['APP_ENV'] == :production,
      path: '/',
      httponly: true
    )
  end
end

module FormatUtils

  def self.parse_json(str = '')
    JSON.parse(str, symbolize_names: true)
  end

  def self.password_hash(password)
    Digest::MD5.hexdigest(password)
  end
end


class JsonWebToken
  class << self
    def encode(payload, exp = Time.now + 24*3600)
      payload[:exp] = exp.to_i
      JWT.encode(payload, ENV['APP_SECRET'])
    end

    # throws JWT::ExpiredSignature < JST::DecodeError if the token is expired
    # throws common JST::DecodeError in all other decoding error cases
    def decode(token)
      body = JWT.decode(token, ENV['APP_SECRET'], true, { leeway: 24*3600} )[0]
      Hash.new.merge! body
    end
  end
end