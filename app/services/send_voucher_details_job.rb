class SendVoucherDetailsJob < ApplicationJob
  queue_as :default

  def perform(voucher_id)
    SendVoucherDetails.call(Voucher.find_by(id: voucher_id))
  end
end
