class AddCrmAttributesToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :setting, :float, default: 0.0
    add_column :reviews, :quality, :float, default: 0.0
    add_column :reviews, :interior, :float, default: 0.0
    add_column :reviews, :communication, :float, default: 0.0
    add_column :reviews, :service, :float, default: 0.0
    add_column :reviews, :suggetion, :text
    add_column :reviews, :title, :string
  end
end
