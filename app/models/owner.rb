class Owner < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :lodgings
  belongs_to :admin_user

  def full_name
    "#{first_name} #{last_name}".titleize
  end
end
