class FixQueryCol < ActiveRecord::Migration
  def up
    change_column :survey_query_predicates, :value, :text, {:default => nil}
  end

  def down
    change_column :survey_query_predicates, :value, :string, {:default => nil}
  end
end
