class AddAcceptanceStatusAndMailingNumber < ActiveRecord::Migration
  def self.up
     add_column :people, :acceptance_status_id, :integer
     add_column :people, :mailing_number, :integer
  end

  def self.down
     remove_column :people, :acceptance_status_id
     remove_column :people, :mailing_number
  end
end
