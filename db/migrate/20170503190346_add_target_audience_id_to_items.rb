class AddTargetAudienceIdToItems < ActiveRecord::Migration
  def change
    add_column :programme_items, :target_audience_id, :integer
    add_column :published_programme_items, :target_audience_id, :integer
  end
end
