class Google::People
  attr_accessor :access_token

  def initialize authorization_code
    @access_token = Google::Authorization.new(authorization_code).access_token
  end

  def user_info
    uri = URI.parse("https://people.googleapis.com/v1/people/me?access_token=#{access_token}&personFields=emailAddresses,names,nicknames")
    https = Net::HTTP.new(uri.host, uri.port);
    https.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request["Content-Type"] = "application/json"
    response = JSON.parse https.request(request).body
    response.has_key?("error") ? nil : response
  end

  def config_user
    response = user_info
    return nil if response.blank?

    User.configure_social_login_user(
      uid: response.dig('emailAddresses')&.first&.dig('metadata', 'source', 'id'),
      email: response.dig('emailAddresses')&.first&.dig('value'),
      provider: SocialLogin::PROVIDERS[:google],
      first_name: response.dig('names').first.dig('familyName'),
      last_name: response.dig('names').first.dig('givenName')
    )
  end
end
