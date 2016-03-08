class AddInviteCategory < ActiveRecord::Migration
  def change
    add_column :person_con_states, :invitation_category_id, :integer, {:default => nil}
  end
end
