class UpdateLodgingSupplements
  attr_reader :lodging,
              :params

  def self.call(lodging:, params:)
    new(lodging: lodging, params: params).call
  end

  def initialize(lodging:, params:)
    @lodging = lodging
    @params = params
  end

  def call
    return if params.blank?

    update_supplements
    update_translations
  end

  private
    def update_supplements
      new_supplements = []
      supplements = lodging.supplements.includes(:linked_supplements)
      children = lodging.belongs_to_channel? ? lodging.children_room_rates.includes(:rate_plan) : lodging.lodging_children
      params.each do |supplement_params|
        supplement = supplements.find { |supplement| supplement.crm_id == supplement_params[:crm_id] } || lodging.supplements.new(created_at: DateTime.current, updated_at: DateTime.current, crm_id: supplement_params[:crm_id])

        supplement_params[:linked_supplements].each do |linked_supplement_params|
          child = lodging.belongs_to_channel? ? children.find { |c| c.rate_plan_crm_id == linked_supplement_params[:rate_plan_crm_id] } : children.find { |c| c.crm_id == linked_supplement_params[:supplementable_crm_id] }
          linked_supplement = supplement.linked_supplements.find { |ls| ls.supplementable_id == child.id && ls.supplementable_type == child.class.name }
          supplement.linked_supplements.build(created_at: DateTime.current, updated_at: DateTime.current, supplementable_id: child.id, supplementable_type: child.class.name) if linked_supplement.blank?
        end
        supplement.attributes = supplement_permitted_params(supplement_params)
        new_supplements << supplement if changed?(supplement)
      end

      return unless new_supplements.present?
      Supplement.import new_supplements, recursive: true, batch_size: 150, on_duplicate_key_update: { columns: Supplement.column_names - %w[id updated_at] }
    end

    def update_translations
      supplements = lodging.supplements.includes(:translations)

      params.each do |supplement_params|
        supplement = supplements.find { |supplement| supplement.crm_id == supplement_params[:crm_id] }

        supplement_params[:translations].each do |translation|
          _translation = supplement.translations.find_or_initialize_by(locale: translation[:locale])
          _translation.attributes = translation_params(translation)
          _translation.save
        end
      end
    end

    def supplement_permitted_params(supplement_params)
      supplement_params.permit(
        :name,
        :description,
        :supplement_type,
        :rate,
        :child_rate,
        :maximum_number,
        :published,
        :valid_permanent,
        :valid_from,
        :valid_till,
        :rate_type,
        valid_on_arrival_days: [],
        valid_on_departure_days: [],
        valid_on_stay_days: []
      )
    end

    def translation_params(translation)
      translation.permit(:name, :description, :locale)
    end

    def changed?(supplement)
      supplement.new_record? || supplement.changed? || supplement.linked_supplements.any? { |ls| ls.new_record? || ls.changed? }
    end
end
