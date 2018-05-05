class CreateAvailabilities < ActiveRecord::Migration[5.1]
  def change
    create_table :availabilities do |t|
      t.date :available_on
      t.references :lodging, foreign_key: true

      t.timestamps
    end
  end
end
