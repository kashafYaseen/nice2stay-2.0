class Voucher < ApplicationRecord
  PREDEFINED_GIFT_AMOUNT = 50

  belongs_to :receiver, class_name: 'User'
  belongs_to :receiver_country, class_name: 'Country'

  accepts_nested_attributes_for :receiver

  validates :sender_name, :sender_email, :receiver_address, :receiver_zipcode, :receiver_city, presence: true, unless: :created_by_nice2stay?
  validates :amount, numericality: { greater_than: 0 }
  validate :accept_terms_and_conditions

  before_validation :check_existing_receiver
  before_create :set_code, :set_expired_at, :set_mollie_amount, :set_created_by
  after_commit :send_details

  scope :unsed, -> { where(used: false) }
  scope :old, -> { where('expired_at < ? OR used = ?', DateTime.current, true) }

  attr_accessor :terms_and_conditions, :skip_data_posting

  enum created_by: {
    random_user: 0,
    customer: 1,
    nice2stay: 2,
  }, _prefix: true

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
      return if created_by_nice2stay?
      return if amount.to_f <= PREDEFINED_GIFT_AMOUNT
      self.mollie_amount = amount.to_f - PREDEFINED_GIFT_AMOUNT
    end

    def set_code
      return if created_by_nice2stay?
      loop do
        self.code = (0...8).map { (65 + rand(26)).chr }.join
        break unless self.class.exists?(code: code)
      end
    end

    def set_expired_at
      return if created_by_nice2stay?
      self.expired_at = DateTime.current + 1.year
    end

    def set_created_by
      return if created_by_nice2stay?
      self.created_by = User.find_by(email: sender_email) ? Voucher.created_bies[:customer] : Voucher.created_bies[:random_user]
    end

    def accept_terms_and_conditions
      return if skip_data_posting
      errors.add(:base, 'Please accept terms and conditions') unless terms_and_conditions
    end

    def send_details
      return if skip_data_posting
      SendVoucherDetailsJob.perform_later(self.id)
    end
end
