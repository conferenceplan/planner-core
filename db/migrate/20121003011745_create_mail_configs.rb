class CreateMailConfigs < ActiveRecord::Migration
  def self.up
    create_table :mail_configs do |t|

      #
      t.string :conference_name, { :default => "" }
      # cc address
      t.string :cc, { :default => "" }
      # from address
      t.string :from, { :default => "" }
      # host domain
      t.string :domain, { :default => "" }
      
      t.timestamps
    end
  end

  def self.down
    drop_table :mail_configs
  end
end

    # cc       "boskone@myconferenceplanning.org"
    # from      "no-reply@myconferenceplanning.org"
