class Page < ApplicationRecord
  translates :title, :meta_title, :short_desc, :content, :category, :slug
end
