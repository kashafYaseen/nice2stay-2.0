class AddAttachmentsToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :attachments, :string, array: true, default: []
  end
end
