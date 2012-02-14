class CreateSurveyFormats < ActiveRecord::Migration
  def self.up
    create_table :survey_formats do |t|
      
      t.integer :sort_order, { :default => 0 }
      t.string :help, { :default => "" }
      t.string :style, { :default => "" }
      t.string :description_style, { :default => "" }
      t.string :answer_style, { :default => "" }
      t.string :question_style, { :default => "" }
      t.integer :textbox_size
      t.integer :textfield_size

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_formats
  end
end
