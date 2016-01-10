class AddPublishedToTagContexts < ActiveRecord::Migration
  def change
    add_column :tag_contexts, :publish, :boolean, {:default => true}
  end
end
