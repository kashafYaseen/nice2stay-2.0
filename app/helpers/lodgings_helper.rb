module LodgingsHelper
  def is_checked?(value, symbol)
    params[symbol].present? && params[symbol].include?(value.to_s)
  end

  def render_min_price(price)
    price || 0
  end

  def render_max_price(price)
    price || 1500
  end

  def render_lodgings_count_for (lodgings, key, filter_name, total_lodgings)
    buckets = lodgings.aggregations[filter_name]['buckets']
    all_buckets = total_lodgings.aggregations[filter_name]['buckets']
    total, actual = 0, 0

    buckets.each do |bucket|
      actual = bucket['doc_count'] if bucket['key'] == key
    end if buckets.present?

    all_buckets.each do |bucket|
      total = bucket['doc_count'] if bucket['key'] == key
    end if all_buckets.present?

    "#{actual} #{t('search.of')} #{total}"
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
    link_to render_lodging_path(lodging), class: "text-decoration-none" do
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
    return t('filters.sort_by') if params[:order].blank?
    return 'Highest to Lowest' if params[:order] == 'price_desc'
    return 'Lowest to Highest' if params[:order] == 'price_asc'
    return 'Highest Rating' if params[:order] == 'rating_desc'
    return 'Newest' if params[:order] == 'new_desc'
  end

  def render_highlight lodging, highlight
    return lodging.send(highlight) unless lodging.as_child?
    lodging.parent.send(highlight)
  end

  def calculation_ids lodging
    return [lodging.id] if lodging.as_standalone?
    lodging.lodging_children.try(:ids)
  end

  def lodging_id lodging
    return lodging.parent if lodging.as_child?
    lodging
  end

  def render_lodging_path lodging
    path = lodging_path(lodging_id(lodging), query_params)
    path += "##{lodging.slug}" if lodging.as_child?
    path
  end

  def query_params
    { check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], infants: params[:infants] }
  end

  def render_price price, dynamic
    return "<h3 class='price'>#{render_rounded_price price}</h3><p class='price-text nights-text'> #{t('search.for')} #{(params[:check_out].to_date - params[:check_in].to_date).to_i} #{t('nav_cart.nights').downcase}</p>".html_safe if dynamic
    "<div class='price-text-from price-text'> #{t('search.from')} </div> <h3 class='price'>#{render_rounded_price price}</h3><p class='price-text nights-text'> per #{t('search.night')}</p>".html_safe
  end
end
