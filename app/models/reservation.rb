class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  after_commit :reindex_lodging

  def reindex_lodging
    lodging.reindex
  end
end
