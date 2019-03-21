module CustomTextsHelper
  def seo_url(path, query_params=nil)
    "#{request.base_url}/#{path}?#{query_params}"
  end
end
