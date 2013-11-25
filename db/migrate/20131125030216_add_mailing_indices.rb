class AddMailingIndices < ActiveRecord::Migration
  def up
    
    add_index :person_mailing_assignments, :mailing_id
    add_index :person_mailing_assignments, :person_id
    
  end

  def down
    
    remove_index :person_mailing_assignments, :mailing_id
    remove_index :person_mailing_assignments, :person_id
    
  end
end
