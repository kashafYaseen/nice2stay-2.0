class UpdateLodgingDiscounts
  attr_reader :lodging
  attr_reader :discounts
  attr_reader :crm_ids

  def self.call(lodging, discounts, crm_ids)
    self.new(lodging, discounts, crm_ids).call
  end

  def initialize(lodging, discounts, crm_ids)
    @lodging = lodging
    @discounts = discounts
    @crm_ids = crm_ids
  end

  def call
    return unless discounts.present?
    update_discounts
  end

  private
    def update_discounts
      lodging.discounts.where.not(crm_id: crm_ids).destroy_all
      discounts.each do |discount_params|
        discount = lodging.discounts.find_or_initialize_by(crm_id: discount_params[:crm_id])
        discount.attributes = discounts_params(discount_params)
        discount.save
      end
    end

    def discounts_params(discount_params)
      discount_params.permit(
        :description,
        :short_desc,
        :publish,
        :discount_type,
        :valid_to,
        :value,
        :crm_id,
        :start_date,
        :end_date,
        :guests,
        { minimum_days: [] },
      )
    end
end
