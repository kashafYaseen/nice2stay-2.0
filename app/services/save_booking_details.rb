class SaveBookingDetails
  attr_reader :params
  attr_reader :booking

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @booking = Booking.find_or_initialize_by(uid: booking_params[:uid])
  end

  def call
    result = save_booking
    update_review_translations if result
    [booking, result]
  end

  private
    def save_booking
      booking.attributes = booking_params
      booking.user = user

      booking.reservations.each_with_index do |reservation, index|
        lodging = Lodging.friendly.find(params[:booking][:reservations_attributes][index][:lodging_slug]) rescue nil
        reservation.lodging = lodging

        if lodging.present?
          lodging.availabilities.check_out_only!(reservation.check_in)
          lodging.availabilities.where(available_on: (reservation.check_in+1.day..reservation.check_out-1.day).map(&:to_s)).destroy_all
          lodging.availabilities.where(available_on: reservation.check_out, check_out_only: true).delete_all
        end

        next unless reservation.review.present?
        reservation.review.user = booking.user
        reservation.review.lodging = reservation.lodging
      end

      booking.save(validate: false)
    end

    def update_review_translations
      booking.reservations.each_with_index do |reservation, index|
        next unless params[:booking][:reservations_attributes][index][:review_attributes].present?
        save_translations(params[:booking][:reservations_attributes][index][:review_attributes][:translations], reservation.review)
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

    def lodging
      Lodging.find_by(slug: params[:reservation][:lodging_slug])
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
        reservations_attributes: [
          :id,
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
          :created_at,
          :updated_at,
          review_attributes: [
            :id,
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
            { images: [] },
            { thumbnails: [] },
            :skip_data_posting,
          ]
        ]
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
end
