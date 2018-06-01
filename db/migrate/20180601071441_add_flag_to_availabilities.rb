class AddFlagToAvailabilities < ActiveRecord::Migration[5.1]
  def change
    add_column :availabilities, :check_out_only, :boolean, default: false
  end
end
