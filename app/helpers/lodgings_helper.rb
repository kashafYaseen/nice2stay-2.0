module LodgingsHelper
  def is_checked?(value)
    params[:lodging_type_in].present? && params[:lodging_type_in].include?(value.to_s)
  end

  def render_min_price(price)
    price || 0
  end

  def render_max_price(price)
    price || 100000
  end

  def count_lodging_type(lodgings, type)
    buckets = lodgings.aggregations['lodging_type']['buckets']
    buckets = lodgings.aggregations['lodging_type']['lodging_type']['buckets'] unless buckets.present?

    buckets.each do |bucket|
      return bucket['doc_count'] if bucket['key'] == type
    end if buckets.present?
    0
  end

  def truncated_description(description)
    return unless description.present?
    return description.truncate(600) if truncate_description?(description)
    description
  end

  def truncate_description?(description)
    return false unless description.present?
    description.split(' ').length > 600
  end
end
