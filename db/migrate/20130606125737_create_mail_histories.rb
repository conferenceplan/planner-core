class CreateMailHistories < ActiveRecord::Migration
  def self.up
    create_table :mail_histories do |t|
      
      t.integer   "person_mailing_assignment_id"       # Mailing
      t.integer   "email_status_id"  # Status, null, pending, success, failed
      t.datetime  "date_sent"        # Date Sent
      t.string    "email"            # Address sent to
      t.text      "content"          # Content of email
      t.boolean   "testrun", :default => false  # indicator that this is a test run

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :mail_histories
  end
end
