class SaveBookingDetails
  attr_reader :params
  attr_reader :booking

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    bookings = Booking.where(uid: params[:booking][:uid])
    bookings.destroy_all if bookings.count > 1
    @booking = Booking.find_or_initialize_by(crm_id: params[:booking][:id])
  end

  def call
    save_booking
    cancel_channel_manager_reservations
    booking
  end

  private
    def save_booking
      booking.attributes = booking_params
      booking.user = user
      booking.created_by = created_by(params[:booking][:created_by])
      booking.save(validate: false)

      return unless params[:booking][:reservations_attributes].present?

      booking.reservations.where.not(id: params[:booking][:reservation_ids]).update_all(canceled: true)

      params[:booking][:reservations_attributes].each do |reservations_attribute|
        reservation = booking.reservations.find_by(id: reservations_attribute[:id]) || booking.reservations.build
        reservation.attributes = reservation_params(reservations_attribute)
        reservation.room_rate = RoomRate.joins(:child_lodging, :rate_plan).find_by(lodgings: { crm_id: reservations_attribute[:child_lodging_crm_id] }, rate_plans: { crm_id: reservations_attribute[:rate_plan_crm_id] })
        lodging = Lodging.find_by(crm_id: reservations_attribute[:lodging_crm_id]) || Lodging.friendly.find(reservations_attribute[:lodging_slug]) rescue nil
        reservation.lodging = lodging if lodging.present?
        reservation_saved = reservation.save(validate: false)

        unless reservation.belongs_to_channel?
          if lodging.present? & reservation_saved && booking.step_passed?(:booked) && !reservation.canceled? && !booking.rebooking_approved?
            lodging.availabilities.check_out_only!(reservation.check_in)
            lodging.availabilities.where(available_on: (reservation.check_in+1.day..reservation.check_out-1.day).map(&:to_s)).destroy_all
            lodging.availabilities.where(available_on: reservation.check_out, check_out_only: true).delete_all
          end

          add_availabilities(reservation.check_in, reservation.check_out, lodging) if booking.rebooking_approved?
        end

        next unless reservations_attribute[:review_attributes].present?
        review = reservation.review || reservation.build_review
        review.attributes = review_params(reservations_attribute[:review_attributes])
        review.user = booking.user
        review.lodging = reservation.lodging
        review.save(validate: false)
        save_translations(reservations_attribute[:review_attributes][:translations], review)
      end
    end

    def save_translations(review_params, review)
      return unless review_params.present?
      review_params.each do |translation|
        _translation = review.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def user
      return unless params[:booking][:user].present?
      password = Devise.friendly_token[0, 20]
      User.where(email: user_params[:email]).first_or_create(user_params.merge(password: password, password_confirmation: password))
    end

    def booking_params
      params.require(:booking).permit(
        :skip_data_posting,
        :uid,
        :created_at,
        :in_cart,
        :confirmed,
        :be_identifier,
        :pre_payment,
        :final_payment,
        :refund_payment,
        :pre_payed_at,
        :final_payed_at,
        :booking_status,
        :crm_id,
        :canceled,
        :final_payment_till,
        :free_cancelation_till,
        :free_cancelation,
        :rebooked,
        :rebooking_approved,
        :owner_name
      )
    end

    def reservation_params reservation
      reservation.permit(
        :check_in,
        :check_out,
        :adults,
        :children,
        :infants,
        :total_price,
        :rent,
        :commission,
        :discount,
        :cleaning_cost,
        :crm_booking_id,
        :skip_data_posting,
        :booking_status,
        :request_status,
        :in_cart,
        :canceled,
        :booked_by,
        :created_at,
        :updated_at,
        :meal_tax,
        :tax,
        :additional_fee,
        :room_type,
        :rooms,
        :gc_errors,
        :gc_policy,
        :guest_centric_booking_id,
        :meal_id,
        :offer_id,
        :security_deposit,
        :include_deposit,
      )
    end

    def review_params review
      review.permit(
        :setting,
        :quality,
        :interior,
        :communication,
        :service,
        :suggetion,
        :title,
        :description,
        :created_at,
        :updated_at,
        :published,
        :perfect,
        :anonymous,
        { images: [] },
        { thumbnails: [] },
        :skip_data_posting,
      )
    end

    def user_params
      params[:booking].require(:user).permit(
        :first_name,
        :last_name,
        :email
      )
    end

    def translation_params(translation)
      translation.permit(
        :title,
        :suggetion,
        :locale,
        :description,
      )
    end

    def created_by value
      return value if Booking.created_bies.keys.include?(value)
      'nice2stay'
    end

    def add_availabilities check_in, check_out, lodging
      a = Availability.find_or_create_by(available_on: check_in, lodging_id: lodging.id)
      a.check_out_only = false
      a.save
      dates = (check_in + 1.day..check_out).map(&:to_s)
      dates.each do |date|
        a = Availability.find_or_create_by(available_on: date, lodging_id: lodging.id)
      end
    end

    def cancel_channel_manager_reservations
      booking.reservations_canceled.belongs_to_channel.each do |reservation|
        next if reservation.canceled_at_channel.present? #already canceled

        OpenGds::CancelReservation.call(reservation) if reservation.open_gds?
        RoomRaccoons::SendReservations.call(reservation: reservation, reservation_status: 'Cancel') if reservation.room_raccoon?
      end
    end
end
