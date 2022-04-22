module MollieCredentials
  def api_key(requesting_site)
    return ENV['MOLLIE_API_KEY']
  end
end
