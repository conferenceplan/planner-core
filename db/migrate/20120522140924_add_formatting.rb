class AddFormatting < ActiveRecord::Migration
  def self.up
    add_column :survey_formats, :formatable_id, :integer
    add_column :survey_formats, :formatable_type, :string
  end

  def self.down
    remove_column :survey_formats, :formatable_id
    remove_column :survey_formats, :formatable_type
  end
  
end
