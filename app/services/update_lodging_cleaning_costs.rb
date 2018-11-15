class UpdateLodgingCleaningCosts
  attr_reader :lodging
  attr_reader :cleaning_costs

  def self.call(lodging, cleaning_costs)
    self.new(lodging, cleaning_costs).call
  end

  def initialize(lodging, cleaning_costs)
    @lodging = lodging
    @cleaning_costs = cleaning_costs
  end

  def call
    return unless cleaning_costs.present?
    update_cleaning_costs
  end

  private
    def update_cleaning_costs
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
