class JsonWebToken
  def self.encode(payload, secret_key=nil)
    JWT.encode(payload, (secret_key || Rails.application.secrets.secret_key_base))
  end

  def self.decode(token, secret_key=nil)
    return HashWithIndifferentAccess.new(JWT.decode(token, (secret_key || Rails.application.secrets.secret_key_base))[0])
    rescue JWT::ExpiredSignature
      "Token Expired"
    rescue
      nil
  end
end
