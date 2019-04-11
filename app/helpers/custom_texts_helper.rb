module CustomTextsHelper
  def seo_url(path, query_params=nil)
    return "#{request.base_url}/#{path}?#{query_params}" if query_params.present?
    "#{request.base_url}/#{path}"
  end
end
