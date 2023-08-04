class AddDeviseInvitableToOwners < ActiveRecord::Migration[5.2]
  def up
    change_table :owners do |t|
      t.string     :invitation_token, index: { unique: true }
      t.datetime   :invitation_created_at
      t.datetime   :invitation_sent_at
      t.datetime   :invitation_accepted_at
      t.references :invited_by, foreign_key: { to_table: :admin_users }
      t.string     :invited_by_type
      t.integer    :invitations_count, default: 0
    end
  end

  def down
    change_table :owners do |t|
      t.remove :invitation_token
      t.remove :invitation_created_at
      t.remove :invitation_sent_at
      t.remove :invitation_accepted_at
      t.remove :invited_by_type
      t.remove_references :invited_by, foreign_key: { to_table: :admin_users }
      t.remove :invitations_count
    end
  end
end
