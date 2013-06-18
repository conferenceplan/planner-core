class CreateMailings < ActiveRecord::Migration
  def self.up
    create_table :mailings do |t|
      
      t.integer  "mailing_number"     # mailing number
      t.integer  "mail_template_id"  # mail template
      t.boolean  "scheduled"          # flag to indicate a mailing has been requested
      t.boolean   "testrun", :default => false  # indicator that this is a test run

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :mailings
  end
end
