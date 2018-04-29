class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :transaction

  after_commit :reindex_transaction

  def reindex_transaction
    transaction.reindex
  end
end
