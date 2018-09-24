module LodgingsHelper
  def is_checked?(value, symbol)
    params[symbol].present? && params[symbol].include?(value.to_s)
  end

  def render_min_price(price)
    price || 0
  end

  def render_max_price(price)
    price || 100000
  end

  def render_lodgings_count_for (lodgings, key, filter_name)
    buckets = lodgings.aggregations[filter_name]['buckets']
    buckets = lodgings.aggregations[filter_name][filter_name]['buckets'] unless buckets.present?

    buckets.each do |bucket|
      return bucket['doc_count'] if bucket['key'] == key
    end if buckets.present?
    0
  end

  def truncated_description(description, break_point)
    return unless description.present?
    return description.truncate(break_point) if truncate_description?(description, break_point)
    description
  end

  def truncate_description?(description, break_point)
    return false unless description.present?
    description.length > break_point
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

  def render_modal_slider_images lodging, options = {}
    return image_tag image_path('default-lodging.png'), options unless lodging.images.present?
    tags = ''
    lodging.images.each { |image_path|  tags << image_tag(image_path, options) }
    tags.html_safe
  end

  def render_sort_text
    return 'Sort By' if params[:order].blank?
    return 'Highest to Lowest' if params[:order] == 'price_desc'
    return 'Lowest to Highest' if params[:order] == 'price_asc'
    return 'Highest Rating' if params[:order] == 'rating_desc'
    return 'Newest' if params[:order] == 'new_desc'
  end
end
