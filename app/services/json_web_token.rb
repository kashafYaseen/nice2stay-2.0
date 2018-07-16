class JsonWebToken
  def self.encode(payload)
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  def self.decode(token)
    return HashWithIndifferentAccess.new(JWT.decode(token, Rails.application.secrets.secret_key_base)[0])
    rescue JWT::ExpiredSignature
      "Token Expired"
    rescue
      nil
  end
end
