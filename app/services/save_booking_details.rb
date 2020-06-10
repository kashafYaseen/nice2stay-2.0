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
        reservation = booking.reservations.not_canceled.find_by(id: reservations_attribute[:id]) || booking.reservations.build
        reservation.attributes = reservation_params(reservations_attribute)
        lodging = Lodging.friendly.find(reservations_attribute[:lodging_slug]) rescue nil
        reservation.lodging = lodging

        if lodging.present? & reservation.save(validate: false) && booking.step_passed?(:booked) && !reservation.canceled?
          lodging.availabilities.check_out_only!(reservation.check_in)
          lodging.availabilities.where(available_on: (reservation.check_in+1.day..reservation.check_out-1.day).map(&:to_s)).destroy_all
          lodging.availabilities.where(available_on: reservation.check_out, check_out_only: true).delete_all
        end

        add_availabilities(reservation.check_in, reservation.check_out, lodging) if params[:booking][:rebooking_approved]

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
        :booking_status,
        :crm_id,
        :canceled,
        :final_payment_till,
        :free_cancelation_till,
        :free_cancelation,
        :rebooked,
        :rebooking_approved,
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
      dates = (check_in..check_out).map(&:to_s)
      dates.each do |date|
        Availability.find_or_create_by(available_on: date, lodging_id: lodging.id) do |availability|
          availability.created_at = availability.updated_at = DateTime.now
        end
      end
    end
end
