class AddClientPublishedToReviews < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :client_published, :boolean, default: true
    add_column :reviews, :nice2stay_feedback, :text
  end
end
