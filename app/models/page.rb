class Page < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  translates :title, :meta_title, :short_desc, :content, :category, :slug

  scope :not_private, -> { where(private: false) }
end
