class AddNotesForParticipantsToItems < ActiveRecord::Migration
  def change
    add_column :programme_items,            :participant_notes, :text, null: true
    add_column :published_programme_items,  :participant_notes, :text, null: true
  end
end
