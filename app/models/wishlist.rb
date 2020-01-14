class Wishlist < ApplicationRecord
  belongs_to :trip
  belongs_to :user
  belongs_to :lodging

  delegate :slug, :name, :image, to: :lodging, prefix: true, allow_nil: true

  enum status: {
   active: 0,
   checkout: 1,
  }

  #after_commit :sync_with_crm

  private
    def sync_with_crm
      SendWishlistDetailsJob.perform_later(self.id) if checkout?
    end
end
