class Authenticate
  initialize(dao) { @dao = dao }

end

class JsonWebToken
  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end

    def decode(token)
      body = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
      HashWithIndifferentAccess.new body
    rescue
      nil
    end
  end
end

def set_jwt_cookie(jwt_payload, cookies)
  cookies[:access_token] = {
    value: jwt_payload,
    expires: Date.today.next_day,
    secure: ENV['APP_ENV'] == :production,
    httponly: true
  }
end