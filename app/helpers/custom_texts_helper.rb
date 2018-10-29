module CustomTextsHelper
  def seo_url(path)
    "#{request.base_url}/#{path}"
  end
end
