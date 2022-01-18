class Voucher < ApplicationRecord
  PREDEFINED_GIFT_AMOUNT = 50

  belongs_to :receiver, class_name: 'User'
  belongs_to :receiver_country, class_name: 'Country'

  accepts_nested_attributes_for :receiver

  validates :sender_name, :sender_email, :receiver_address, :receiver_zipcode, :receiver_city, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validate :accept_terms_and_conditions

  before_validation :check_existing_receiver
  before_create :set_code, :set_expired_at, :set_mollie_amount
  after_commit :send_details

  scope :unsed, -> { where(used: false) }
  scope :old, -> { where('expired_at < ? OR used = ?', DateTime.current, true) }

  attr_accessor :terms_and_conditions

  private
    def check_existing_receiver
      existing_receiver = User.find_by(email: receiver.email)
      if existing_receiver.present?
        self.receiver_id = existing_receiver.id
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

    def set_mollie_amount
      return if amount.to_f <= PREDEFINED_GIFT_AMOUNT
      self.mollie_amount = amount.to_f - PREDEFINED_GIFT_AMOUNT
    end

    def set_code
      loop do
        self.code = (0...8).map { (65 + rand(26)).chr }.join
        break unless self.class.exists?(code: code)
      end
    end

    def set_expired_at
      self.expired_at = DateTime.current + 1.year
    end

    def accept_terms_and_conditions
      errors.add(:base, 'Please accept terms and conditions') unless terms_and_conditions
    end

    def send_details
      SendVoucherDetailsJob.perform_later(self.id)
    end
end
