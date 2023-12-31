class Google::Authorization
  attr_reader :authorization_code
  attr_reader :redirect_uri

  def initialize (params)
    @redirect_uri = params[:redirect_uri]
    @authorization_code = params[:code]
  end

  def access_token
    uri = URI.parse("https://accounts.google.com/o/oauth2/token")
    https = Net::HTTP.new(uri.host, uri.port);
    https.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = payload.to_json
    response = JSON.parse https.request(request).body
    puts "Response of AuthorizationCode: #{response}"
    response.has_key?("error") ? nil : response.dig('access_token')
  end

  def payload
    {
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://www.googleapis.com/oauth2/v3/token',
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      grant_type: 'authorization_code',
      code: authorization_code,
      redirect_uri: redirect_uri
    }
  end
end
