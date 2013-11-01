class AddLayoutToQuestion < ActiveRecord::Migration
  def change
    add_column :survey_questions, :horizontal, :boolean, :default => false
  end
end
