class SendVoucherDetails
  attr_reader :voucher
  attr_reader :uri

  def self.call(voucher)
    self.new(voucher).call
  end

  def initialize(voucher)
    @voucher = voucher
    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/vouchers")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = voucher_details.to_json
    http.request(request)
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def voucher_details
      {
        voucher: {
          fe_id: voucher.id,
          sender_name: voucher.sender_name,
          sender_email: voucher.sender_email,
          amount: voucher.amount,
          send_by_post: voucher.send_by_post,
          message: voucher.message,
          receiver_attributes: receiver_attributes,
          receiver_city: voucher.receiver_city,
          receiver_zipcode: voucher.receiver_zipcode,
          receiver_address: voucher.receiver_address,
          receiver_country_id: voucher.receiver_country.crm_id,
          code: voucher.code,
          used: voucher.used,
          expired_at: voucher.expired_at,
        }
      }
    end

    def receiver_attributes
      {
        name: voucher.receiver.first_name,
        surname: voucher.receiver.first_name,
        email: voucher.receiver.email,
        city: voucher.receiver.city,
        zip: voucher.receiver.zipcode,
        address: voucher.receiver.address,
        country_id: voucher.receiver.country.crm_id,
      }
    end
end
