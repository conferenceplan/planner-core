class AddToHistory < ActiveRecord::Migration
  def self.up
    add_column :mail_histories, :person_id, :integer
    add_column :mail_histories, :mailing_id, :integer
  end

  def self.down
    remove_column :mail_histories, :person_id
    remove_column :mail_histories, :mailing_id
  end
end
