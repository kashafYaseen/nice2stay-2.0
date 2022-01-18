class VoucherMollieCustomer
  attr_reader :voucher, :sender, :customer

  def initialize(voucher:, sender:)
    @voucher = voucher
    @sender = sender
    @customer = find_or_create
  end

  private
    def find_or_create
      existing_sender = Voucher.where(sender_email: sender[:email]).where.not(sender_mollie_id: nil).last
      if existing_sender.try(:sender_mollie_id).present?
        voucher.update_column(:sender_mollie_id, existing_sender.sender_mollie_id) unless voucher.sender_mollie_id.present?
        return Mollie::Customer.get(existing_sender.sender_mollie_id)
      end
      create
    end

    def create
      customer = Mollie::Customer.create(name: sender[:full_name], email: sender[:email])
      voucher.update_column :sender_mollie_id, customer.id
      return customer
    end
end
