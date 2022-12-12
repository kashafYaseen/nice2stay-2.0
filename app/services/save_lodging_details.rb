
class SaveLodgingDetails
  attr_reader :params
  attr_reader :lodging

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @lodging = Lodging.find_by(crm_id: lodging_params[:crm_id]) || Lodging.friendly.find(lodging_params[:slug]) rescue Lodging.new
  end

  def call
    save_lodging
    lodging
  end

  private
    def save_lodging
      lodging.owner = owner
      lodging.region = region(params[:lodging][:country_crm_id], params[:lodging][:region_crm_id])
      lodging.parent = parent
      lodging.lodging_category = lodging_category(params[:lodging][:lodging_category_id])
      lodging.channel = 'open_gds' if params[:lodging][:open_gds]
      lodging.channel = 'room_raccoon' if params[:lodging][:room_raccoon]
      lodging.attributes = lodging_params.merge(lodging_type: lodging_type(params[:lodging][:lodging_type]), crm_synced_at: DateTime.current)
      return unless lodging.save(validate: false)

      UpdateLodgingRatePlans.call(lodging: lodging, parent_rate_plans: params[:lodging][:parent_rate_plans], room_rates: params[:lodging][:room_rates]) if lodging.belongs_to_channel?
      UpdateLodgingSupplements.call(lodging: lodging, params: params[:supplements])
      UpdateLodgingTranslations.call(lodging, params[:translations])
      UpdateLodgingPriceText.call(lodging, params[:price_text])
      return unless lodging.published?

      unless lodging.belongs_to_channel?
        Rails.logger.info "Sync Lodging In UpdatePrices Block ==================>>>>>>>>>>> #{lodging.name}"
        Rails.logger.info "Sync Lodging Channel ==================>>>>>>>>>>> #{lodging.channel} =======> OpenGDS: #{params[:lodging][:open_gds]}"
        UpdateLodgingPrices.call(lodging, params[:lodging][:prices])
        UpdateLodgingAvailabilities.call(lodging, params[:not_available_days])
      end

      UpdateLodgingCleaningCosts.call(lodging, params[:cleaning_costs], params[:cleaning_cost_ids])
      UpdateLodgingDiscounts.call(lodging, params[:discounts], params[:discount_ids])
      update_amenities
      update_experiences
      update_place_categories
    end

    def update_amenities
      amenities = Amenity.where(slug: params[:amenities])
      lodging.amenities = amenities
    end

    def update_experiences
      experiences = Experience.where(slug: params[:experiences])
      lodging.experiences = experiences
    end

    def update_place_categories
      place_categories = PlaceCategory.where(slug: params[:place_categories])
      lodging.place_categories = place_categories
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

    def region(country_crm_id, region_crm_id)
      country = Country.find_by(crm_id: country_crm_id)
      country.regions.find_by(crm_id: region_crm_id) if country.present?
    end

    def lodging_category(lodging_category_id)
      LodgingCategory.find_by(crm_id: lodging_category_id)
    end

    def parent
      Rails.logger.info "Params[:parent] ==================> #{params[:parent].present?}"
      return unless params[:parent].present?

      _parent = Lodging.find_by(crm_id: parent_params[:crm_id]) || Lodging.friendly.find(parent_params[:slug]) rescue Lodging.new
      _parent.owner = owner
      _parent.region = region(params[:parent][:country_crm_id], params[:parent][:region_crm_id])
      _parent.attributes = parent_params.merge(lodging_type: lodging_type(params[:parent][:lodging_type]), crm_synced_at: DateTime.current)
      _parent.save
      _parent
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
        :confirmed_price_2020,
        :dynamic_prices,
        :include_cleaning,
        :deposit,
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
        :guest_centric_id,
        :guest_centric,
        :realtime_availability,
        :gc_username,
        :gc_password,
        { images: [] },
        { thumbnails: [] },
        { attachments: [] },
        { gc_rooms: [] },
        :crm_id,
        :free_cancelation,
        :open_gds_property_id,
        :open_gds_accommodation_id,
        :extra_beds,
        :extra_beds_for_children_only,
        :num_of_accommodations,
        :name_on_cm
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
        :crm_id,
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
        :confirmed_price,
        { images: [] },
      )
    end
end
