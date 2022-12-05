class SocialLogin < ApplicationRecord
  belongs_to :user

  SOCIAL_SITES = [:facebook, :google_oauth2, :instagram]
  PROVIDERS = {
    facebook: 'facebook',
    google: 'google',
    instagram: 'instagram'
  }

  scope :confirmed, -> { where.not(confirmed_at: nil) }
end
