class CustomText < ApplicationRecord
  translates :h1_text, :p_text, :meta_title, :meta_description, :redirect_url, :country, :region, :category, :experience

  def seo_path
    path = ""
    path += "/#{country}" if country?
    path += "/#{region}" if region?
    path += "/#{category}" if category?
    path += "/#{experience}" if experience?
  end
end
