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
          receiver_country_id: voucher.try(:receiver_country).try(:crm_id),
          code: voucher.code,
          used: voucher.used,
          expired_at: voucher.expired_at,
          payment_status: voucher.payment_status,
          payed_at: voucher.payed_at,
          mollie_amount: voucher.mollie_amount,
          created_by: voucher.created_by,
        }
      }
    end

    def receiver_attributes
      {
        name: voucher.try(:receiver).try(:first_name),
        surname: voucher.try(:receiver).try(:last_name),
        email: voucher.try(:receiver).try(:email),
        city: voucher.try(:receiver).try(:city),
        zip: voucher.try(:receiver).try(:zipcode),
        address: voucher.try(:receiver).try(:address),
        country_id: voucher.try(:receiver).try(:country).try(:crm_id),
      }
    end
end
