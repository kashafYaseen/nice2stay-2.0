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

  def render_lodgings_count_for (lodgings, key, filter_name)
    buckets = lodgings.aggregations[filter_name]['buckets']
    return 0 unless buckets.present?

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
    path = lodging_path(lodging_id(lodging), check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], infants: params[:infants])
    path += "##{lodging.slug}" if lodging.as_child?
    path
  end

  def render_price price, dynamic
    return "<h3>#{render_rounded_price price}</h3><p class='price-text'> for #{(params[:check_out].to_date - params[:check_in].to_date).to_i} nights</p>".html_safe if dynamic
    "<div class='price-text'> From </div> <h3>#{render_rounded_price price}</h3><p class='price-text'> per night</p>".html_safe
  end

  def jeo_json lodgings
    markers = []
    lodgings.each do |lodging|
      markers << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [lodging.longitude, lodging.latitude]
        },
        properties: {
          id: lodging.id,
          title: lodging.name,
          url: "#{lodging_path(lodging)}",
          image: (lodging.images.try(:first) || image_path('default-lodging.png')),
          'marker-color': marker_color(lodging),
          'marker-size': 'large',
          'marker-symbol': lodging.lodging_type[0],
        }
      }
    end
    markers.to_json
  end

  def marker_color(lodging)
    return '#1F618D' if lodging.villa?
    return '#7D3C98' if lodging.apartment?
    '#dc9813'
  end
end
