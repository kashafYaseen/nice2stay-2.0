class CreateLodgingCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :lodging_categories do |t|
      t.string :name
      t.integer :crm_id

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        LodgingCategory.create_translation_table!({
          name: :string
        })
      end

      dir.down do
        LodgingCategory.drop_translation_table!
      end
    end

  end
end
