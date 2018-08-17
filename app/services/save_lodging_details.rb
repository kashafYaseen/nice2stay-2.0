class SaveLodgingDetails
  attr_reader :params
  attr_reader :lodging

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @lodging = Lodging.find_or_initialize_by(slug: lodging_params[:slug])
  end

  def call
    save_lodging
    lodging
  end

  private
    def save_lodging
      lodging.owner = owner
      lodging.region = region(params[:lodging][:country_name], params[:lodging][:region_name])
      lodging.parent = parent
      lodging.attributes = lodging_params.merge(lodging_type: lodging_type(params[:lodging][:lodging_type]), crm_synced_at: DateTime.current)
      return unless lodging.save
      UpdateLodgingPrices.call(lodging, params[:lodging][:prices])
      UpdateLodgingTranslations.call(lodging, params[:translations])
      UpdateLodgingAvailabilities.call(lodging, params[:not_available_days])
    end

    def owner
      password = Devise.friendly_token[0, 20]
      Owner.where(email: owner_params[:email]).first_or_create(owner_params.merge(password: password, password_confirmation: password))
    end

    def region(country_name, region_name)
      Region.find_or_create_region(country_name, region_name)
    end

    def parent
      return unless params[:parent].present?

      Lodging.find_or_create_by(slug: parent_params[:slug]) do |parent|
        parent.owner = owner
        parent.region = region(params[:parent][:country_name], params[:parent][:region_name])
        parent.attributes = parent_params.merge(lodging_type: lodging_type(params[:parent][:lodging_type]), crm_synced_at: DateTime.current)
      end
    end

    def lodging_type(type)
      return 'villa' if ['villa', 'villas', 'vakantiehuizen'].include?(type)
      return 'apartment' if ['apartment', 'apartments', 'appartementen'].include?(type)
      'bnb'
    end

    def lodging_params
      params.require(:lodging).permit(
        :street,
        :city,
        :zip,
        :state,
        :beds,
        :baths,
        :sq__ft,
        :sale_date,
        :price,
        :latitude,
        :longitude,
        :adults,
        :children,
        :infants,
        :title,
        :subtitle,
        :description,
        :owner_id,
        :slug,
        :name,
        :meta_title,
        :h1,
        :h2,
        :h3,
        :highlight_1,
        :highlight_2,
        :highlight_3,
        :label,
        :summary,
        :location_description,
        :meta_desc,
        :short_desc,
        :published,
        :heads,
        :confirmed_price,
        :include_cleaning,
        :include_deposit,
        :checked,
        :flexible,
        :listed_to,
        :ical_validated,
        :route_updated_at,
        :price_updated_at,
        :status,
        :region_id,
        :check_in_day,
        :presentation,
        { images: [] },
        specifications_attributes: [:id, :title, :description],
        reviews_attributes: [:id, :user_id, :stars, :description],
        availabilities_attributes: [:id, :available_on, :check_out_only, prices_attributes: [:id, :amount, :adults, :infants, :children]],
        rules_attributes: [:id, :start_date, :end_date, :days_multiplier, :check_in_days],
        discounts_attributes: [:id, :start_date, :end_date, :reservation_days, :discount_percentage],
      )
    end

    def owner_params
      params.require(:owner).permit(
        :first_name,
        :last_name,
        :email
      )
    end

    def parent_params
      params.require(:parent).permit(
        :slug,
        :name,
        :title,
        :status,
        :latitude,
        :longitude,
        :price,
        :check_in_day,
        :street,
        :adults,
        :children,
        :infants,
        :presentation,
        { images: [] },
      )
    end
end
