class AddAnonymousToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :anonymous, :boolean, {:default => false}
  end
end
