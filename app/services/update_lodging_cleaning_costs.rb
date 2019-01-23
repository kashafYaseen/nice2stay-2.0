class UpdateLodgingCleaningCosts
  attr_reader :lodging
  attr_reader :cleaning_costs
  attr_reader :crm_ids

  def self.call(lodging, cleaning_costs, crm_ids)
    self.new(lodging, cleaning_costs, crm_ids).call
  end

  def initialize(lodging, cleaning_costs, crm_ids)
    @lodging = lodging
    @cleaning_costs = cleaning_costs
    @crm_ids = crm_ids
  end

  def call
    return unless cleaning_costs.present?
    update_cleaning_costs
  end

  private
    def update_cleaning_costs
      lodging.cleaning_costs.where.not(crm_id: crm_ids).destroy_all
      cleaning_costs.each do |cost_params|
        cleaning_cost = lodging.cleaning_costs.find_or_initialize_by(crm_id: cost_params[:crm_id])
        cleaning_cost.attributes = cleaning_costs_params(cost_params)
        update_translations(cleaning_cost, cost_params) if cleaning_cost.save
      end
    end

    def update_translations(cleaning_cost, cost_params)
      return unless cost_params[:translations].present?
      cost_params[:translations].each do |translation|
        _translation = cleaning_cost.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def cleaning_costs_params(cost_params)
      cost_params.permit(
        :crm_id,
        :name,
        :fixed_price,
        :price_per_day,
        :guests,
        :manage_by,
      )
    end

    def translation_params(translation)
      translation.permit(
        :name,
        :locale,
      )
    end
end
