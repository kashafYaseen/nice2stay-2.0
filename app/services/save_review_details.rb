class SaveReviewDetails
  attr_reader :params
  attr_reader :review

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @review = Review.find_by(id: params[:review][:id]) || Review.new
  end

  def call
    save_review
    review
  end

  private
    def save_review
      review.attributes = review_params
      review.user = user
      review.lodging = Lodging.friendly.find(params[:review][:lodging_slug]) rescue nil
      review.reservation = Reservation.find_by(id: params[:review][:reservation_id])
      review.anonymous = true unless review.user.present? && review.reservation.present?
      review.save(validate: false)
      save_translations(params[:review][:translations])
    end

    def save_translations(review_params)
      return unless review_params.present?
      review_params.each do |translation|
        _translation = review.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def user
      return unless params[:review][:user].present?
      password = Devise.friendly_token[0, 20]
      User.where(email: user_params[:email]).first_or_create(user_params.merge(password: password, password_confirmation: password))
    end

    def review_params
      params.require(:review).permit(
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
      params[:review].require(:user).permit(
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
