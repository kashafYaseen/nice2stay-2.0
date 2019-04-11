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
      UpdateLodgingTranslations.call(lodging, params[:translations])
      UpdateLodgingPriceText.call(lodging, params[:price_text])
      return unless lodging.published?
      UpdateLodgingPrices.call(lodging, params[:lodging][:prices])
      UpdateLodgingAvailabilities.call(lodging, params[:not_available_days])
      UpdateLodgingCleaningCosts.call(lodging, params[:cleaning_costs], params[:cleaning_cost_ids])
      UpdateLodgingDiscounts.call(lodging, params[:discounts], params[:discount_ids])
      update_amenities
      update_experiences
    end

    def update_amenities
      amenities = Amenity.where(slug: params[:amenities])
      lodging.amenities = amenities
    end

    def update_experiences
      experiences = Experience.where(slug: params[:experiences])
      lodging.experiences = experiences
    end

    def owner
      return unless params[:owner].present?
      house_owner = Owner.find_or_initialize_by(email: owner_params[:email])
      house_owner.attributes = owner_params.merge(admin_user: admin_user)
      house_owner.save(validate: false)
      house_owner
    end

    def admin_user
      return unless params[:admin_user].present?
      admin = AdminUser.find_or_initialize_by(email: admin_user_params[:email])
      admin.attributes = admin_user_params
      admin.save(validate: false)
      admin
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
        :minimum_adults,
        :minimum_children,
        :minimum_infants,
        :region_page,
        :country_page,
        :home_page,
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
        :flexible_arrival,
        :listed_to,
        :ical_validated,
        :route_updated_at,
        :price_updated_at,
        :status,
        :region_id,
        :check_in_day,
        :presentation,
        :created_at,
        :updated_at,
        :boost,
        :optimize_at,
        { images: [] },
        { thumbnails: [] },
        { attachments: [] },
      )
    end

    def owner_params
      params.require(:owner).permit(
        :first_name,
        :last_name,
        :email
      )
    end

    def admin_user_params
      params.require(:admin_user).permit(
        :first_name,
        :last_name,
        :image,
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
