class AddImageToExperience < ActiveRecord::Migration[5.2]
  def change
    add_column :experiences, :image, :string
  end
end
