module MollieCredentials
  def api_key(requesting_site)
    return ENV['MOLLIE_HB_API_KEY'] if requesting_site == 'hotelandbeyond'

    ENV['MOLLIE_API_KEY']
  end
end
