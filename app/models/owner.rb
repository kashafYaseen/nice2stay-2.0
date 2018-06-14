class Owner < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :lodgings
  mount_uploader :image, ImageUploader

  def full_name
    "#{first_name} #{last_name}".titleize
  end
end
