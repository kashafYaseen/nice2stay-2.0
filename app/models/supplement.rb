class Supplement < ApplicationRecord
  belongs_to :lodging # parent/standalone accommodations
  has_many :linked_supplements
  has_many :linked_room_rates, through: :linked_supplements, source: :supplementable, source_type: 'RoomRate'
  has_many :linked_lodgings, through: :linked_supplements, source: :supplementable, source_type: 'Lodging'
  has_many :rate_plans, through: :linked_room_rates

  attr_accessor :calculated_data

  scope :published, -> { where(published: true) }
  scope :applied_room_rates_supplements, -> (check_in, check_out, adults, children, lodging_adults) do
    _extra_adults = extra_adults(lodging_adults, adults)
    _extra_children = extra_children(_extra_adults[-1], children)
    extra_guests = _extra_adults[0] + _extra_children
    joins(linked_room_rates: :child_lodging).where(
      '(supplements.valid_permanent = true OR (supplements.valid_from <= :check_in AND supplements.valid_till >= :check_out)) AND
      :check_in_day = ANY(supplements.valid_on_arrival_days) AND :check_out_day = ANY(supplements.valid_on_departure_days) AND supplements.valid_on_stay_days @> :stay_days AND
      ((lodgings.minimum_adults <= :guests AND lodgings.adults >= :guests) OR
      ((lodgings.extra_beds != 0 AND lodgings.extra_beds >= :extra_guests AND lodgings.minimum_adults <= :guests AND lodgings.adults < :guests) AND
      (lodgings.extra_beds >= :extra_children OR (lodgings.extra_beds >= :extra_adults AND lodgings.extra_beds_for_children_only = false))))',
      check_in: check_in, check_out: check_out, guests: (adults + children), extra_adults: (_extra_adults[0].zero? ? 999 : _extra_adults[0]), extra_children: (_extra_children.zero? ? 999 : _extra_children), extra_guests: extra_guests,
      check_in_day: Date.parse(check_in).strftime('%a'), check_out_day: Date.parse(check_out).strftime('%a'), stay_days: stay_days(check_in, check_out)
    ).distinct
  end

  scope :applied_lodgings_supplements, -> (check_in, check_out, adults, children, symbol) do
    joins(symbol).where(
      '(supplements.valid_permanent = true OR (supplements.valid_from <= :check_in AND supplements.valid_till >= :check_out)) AND
      :check_in_day = ANY(supplements.valid_on_arrival_days) AND :check_out_day = ANY(supplements.valid_on_departure_days) AND supplements.valid_on_stay_days @> :stay_days AND
      lodgings.minimum_adults <= :adults AND lodgings.adults >= :adults AND coalesce(lodgings.minimum_children, 0) <= :min_children AND coalesce(lodgings.children, 0) >= :max_children',
      check_in: check_in, check_out: check_out, adults: adults, min_children: (children.zero? ? 999 : children), max_children: (children.zero? ? 0 : children),
      check_in_day: Date.parse(check_in).strftime('%a'), check_out_day: Date.parse(check_out).strftime('%a'), stay_days: stay_days(check_in, check_out)
    )
  end

  translates :name, :description
  globalize_accessors

  enum supplement_type: {
    optional: 0,
    mandatory: 1
  }

  enum rate_type: {
    'Per Piece': 0,
    'Per Piece Per Day': 1,
    'Per Piece Per Night': 2,
    'Per Person': 3,
    'Per Person Per Day': 4,
    'Per Person Per Night': 5,
    'Per Stay': 6,
    'Per Stay Per Day': 7,
    'Per Stay Per Night': 8,
  }

  def elements(adults, children)
    if rate_type_includes_person?
      element_types = ['adults']
      element_types += ['children'] if children.positive?
    elsif rate_type_includes_piece?
      element_types = ['quantity']
    else
      element_types = ['stay']
    end

    element_types.map { |element_type|
      { id: element_type, type: type, options: options((rate_type_includes_person? && eval("#{element_type}")) || 0)  }
    }
  end

  def rate_type_includes_person?
    ['Per Person', 'Per Person Per Day', 'Per Person Per Night'].include?(self.rate_type)
  end

  def rate_type_includes_piece?
    ['Per Piece', 'Per Piece Per Day', 'Per Piece Per Night'].include?(self.rate_type)
  end

  def rate_type_includes_stay?
    ['Per Stay', 'Per Stay Per Day', 'Per Stay Per Night'].include?(self.rate_type)
  end

  def cumulative_price(params)
    return unless params[:check_in].present? && params[:check_out].present?

    supplement.calculated_data = CalculateSupplementsPrices.call(supplement: self, params: params.merge(selected_adults: params[:adults].to_i, selected_children: params[:children].to_i, quantity: params[:quantity].to_i))
    supplement.calculated_data
  end

  private
    def type
      return 'checkbox' if rate_type_includes_stay?
      return 'select' if rate_type_includes_piece?
      'radio'
    end

    def options(guests = 0)
      return (0..maximum_number.to_i).to_a if rate_type_includes_piece?
      return (0..guests.to_i).to_a if rate_type_includes_person?
      [true, false] # for stay rate types
    end

    def self.extra_adults(lodging_adults, adults)
      adults_without_extra_beds = lodging_adults.to_i - adults.to_i
      adults_with_extra_beds = adults_without_extra_beds.positive? ? 0 : adults_without_extra_beds.abs
      [adults_with_extra_beds, adults_without_extra_beds]
    end

    def self.extra_children(adults_without_extra_beds, children)
      return 0 if children.zero?

      children_with_extra_beds = adults_without_extra_beds - children.to_i
      children_with_extra_beds = children_with_extra_beds.negative? ? children_with_extra_beds.abs : 0
      children_with_extra_beds -= adults_without_extra_beds.abs if adults_without_extra_beds.negative?
      children_with_extra_beds
    end

    def self.stay_days(check_in, check_out)
      _stay_days = '{'
      stays = (Date.parse(check_in) + 1..Date.parse(check_out) - 1).to_a
      stays.each_with_index do |date, index|
        _stay_days += "#{ date.strftime('%a') }"
        _stay_days += ', ' unless index == stays.length - 1
      end

      _stay_days += '}'
    end
end
