class Voucher < ApplicationRecord
  belongs_to :receiver, class_name: 'User'
  belongs_to :receiver_country, class_name: 'Country'

  accepts_nested_attributes_for :receiver

  validates :sender_name, :sender_email, :receiver_address, :receiver_zipcode, :receiver_city, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 10 }

  before_validation :check_existing_receiver

  private
    def check_existing_receiver
      existing_receiver = User.find_by(email: receiver.email)
      if existing_receiver.present?
        self.receiver = existing_receiver
      else
        self.receiver.attributes = new_receiver_attributes
      end
      self.receiver.skip_validations = true
    end

    def new_receiver_attributes
      random_password = Devise.friendly_token[0, 20]
      {
        address: receiver_address,
        zipcode: receiver_zipcode,
        city: receiver_city,
        country: receiver_country,
        password: random_password,
        password_confirmation: random_password
      }
    end
end
