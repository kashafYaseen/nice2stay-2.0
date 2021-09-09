class AddFieldsInExperiences < ActiveRecord::Migration[5.2]
  def change
    add_column :experiences, :priority, :integer, default: 2
    add_column :experiences, :guests, :integer, default: 999
  end
end
