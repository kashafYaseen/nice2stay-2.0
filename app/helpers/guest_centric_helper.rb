module GuestCentricHelper
  def get_centric_param(key)
    params[key] || params[:reservation].present? ? params[:reservation][key] : nil
  end

  def render_guest_centric_images child, options = {}
    return image_tag image_path('default-lodging.png'), options unless child['fullImages'].present?
    tags = ''
    child['fullImages'].each { |image_path|  tags << image_tag(image_path, options) }
    tags.html_safe
  end
end
