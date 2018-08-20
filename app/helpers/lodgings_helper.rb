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

  def no_of_adults(adults)
    return 1 if adults == 0
    adults
  end

  def render_image_tag lodging, options = {}
    image_tag lodging.images.try(:first) || image_path('default-lodging.png'), options
  end

  def render_image_tags lodging, options = {}
    return image_tag_with_link(lodging, image_path('default-lodging.png'), options) unless lodging.images.present?
    tags = ''
    lodging.images.take(5).each { |image_path|  tags << image_tag_with_link(lodging, image_path, options) }
    tags.html_safe
  end

  def image_tag_with_link lodging, image_path, options = {}
    link_to lodging_path(lodging, check_in: params[:check_in], check_out: params[:check_out]), class: "text-decoration-none" do
      image_tag(image_path, options)
    end
  end
end
