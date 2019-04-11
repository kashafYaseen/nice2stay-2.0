class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable


  def full_name
    "#{first_name} #{last_name}"
  end
end
