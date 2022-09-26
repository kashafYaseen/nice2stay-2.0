class SendBookingDetails
  attr_reader :booking
  attr_reader :uri

  def self.call(booking)
    self.new(booking).call
  end

  def initialize(booking)
    @booking = booking
    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/bookings")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = booking_details.to_json
    response = http.request(request)
    update_reservation_ids(response) if response.kind_of? Net::HTTPSuccess
    response
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def booking_details
      {
        booking: {
          customer: customer(booking.user),
          booking_accommodations_attributes: booking_accommodations,
          by_houseowner: false,
          created_by: booking.created_by,
          uid: booking.uid,
          created_at: booking.created_at,
          fe_identifier: booking.identifier,
          skip_data_posting: true,
          status: booking.booking_status,
          fe_id: booking.id,
          pre_payment: booking.pre_payment,
          final_payment: booking.final_payment,
          voucher_code: booking.voucher_code,
          voucher_amount: booking.voucher_amount,
          prepayment_received_date: booking.pre_payed_at,
          finalpayment_received_date: booking.final_payed_at,
        }
      }
    end

    def booking_accommodations
      reservations = []
      booking.reservations.not_canceled.unexpired.order(:id).each do |reservation|
        reservations << {
          id: reservation.crm_booking_id,
          front_end_id: reservation.id,
          accommodation_slug: accommodation_slug(reservation),
          from: reservation.check_in,
          to: reservation.check_out,
          persons_number: reservation.adults,
          children_number: reservation.children,
          babies: reservation.infants,
          total_price: reservation.total_price,
          rental_price: reservation.rent,
          discount: reservation.discount,
          cleaning_cost_price: reservation.cleaning_cost,
          status: reservation.booking_status,
          booking_status: reservation.booking_status,
          canceled: reservation.canceled,
          meal_tax: reservation.meal_tax,
          tax: reservation.tax,
          additional_fee: reservation.additional_fee,
          room_type: reservation.room_type,
          rooms: reservation.rooms,
          gc_errors: reservation.gc_errors,
          gc_policy: reservation.gc_policy,
          guest_centric_booking_id: reservation.guest_centric_booking_id,
          meal_id: reservation.meal_id,
          offer_id: reservation.offer_id,
          by_houseowner: false,
          skip_data_posting: true,
          child_accommodation_id: reservation.child_lodging_crm_id,
          rate_plan_id: reservation.rate_plan_crm_id,
          rr_res_id_value: reservation.rr_res_id_value,
          rr_errors: reservation.rr_errors,
          open_gds_res_id: reservation.open_gds_res_id,
          open_gds_error_name: reservation.open_gds_error_name,
          open_gds_error_message: reservation.open_gds_error_message,
          open_gds_error_code: reservation.open_gds_error_code,
          open_gds_error_status: reservation.open_gds_error_status,
          open_gds_payment_hash: reservation.open_gds_payment_hash,
          open_gds_deposit_amount: reservation.open_gds_deposit_amount,
          open_gds_payment_status: reservation.open_gds_payment_status,
          book_option: reservation.book_option,
          cancel_option_reason: reservation.cancel_option_reason,
          canceled_by: reservation.canceled_by,
          guest_details_attributes: guest_details(reservation),
          booking_request_attributes: { status: request_status(reservation.request_status) }
        }
      end
      return reservations
    end

    def guest_details(reservation)
      details = []
      reservation.guest_details.each do |guest|
        details << {
          fe_id: guest.id,
          age: guest.age,
          type: GuestDetail.guest_types[guest.guest_type.to_sym],
          name: guest.name,
        }
      end
      details
    end

    def customer(user)
      {
        email: user.email,
        name: user.first_name,
        surname: user.last_name,
        address: user.address,
        city: user.city,
        country_slug: user.country_slug,
        phone: user.phone,
        language: user.language,
        sign_in_count: user.sign_in_count,
      }
    end

    def request_status(status)
      return 'new' if status == 'pending'
      return 'accept' if status == 'confirmed'
      'reject'
    end

    def update_reservation_ids(response)
      crm_booking = JSON.parse response.body
      booking.update_column :crm_id, crm_booking['id']
      crm_booking['booking_accommodation'].each do |booking_accommodation|
        reservation = booking.reservations.not_canceled.find_by(id: booking_accommodation['front_end_id'])
        next unless reservation.present?
        reservation.update_column :crm_booking_id, booking_accommodation['id']
      end
    end

    def accommodation_slug(reservation)
      return reservation.child_lodging_slug if reservation.belongs_to_channel?

      reservation.lodging_slug
    end
end
