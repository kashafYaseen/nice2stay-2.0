class AddPrivateToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :private, :boolean, default: false
  end
end
