module LodgingsHelper
  def is_checked?(value)
    params[:lodging_type_in].present? && params[:lodging_type_in].include?(value.to_s)
  end

  def render_min_price(price)
    price || 0
  end

  def render_max_price(price)
    price || 1000
  end
end
