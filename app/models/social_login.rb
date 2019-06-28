class SocialLogin < ApplicationRecord
  belongs_to :user

  SOCIAL_SITES = [:facebook, :google_oauth2, :instagram]
end
