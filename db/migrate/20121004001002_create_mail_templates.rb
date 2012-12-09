class CreateMailTemplates < ActiveRecord::Migration
  def self.up
    create_table :mail_templates do |t|

      t.integer :mail_use_id
      t.string :title, { :default => "" }
      t.string :subject, { :default => "" }
      t.text :content, { :default => "" }
      
      t.references :survey

      t.timestamps
    end
  end

  def self.down
    drop_table :mail_templates
  end
end
