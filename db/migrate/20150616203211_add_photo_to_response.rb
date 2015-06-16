class AddPhotoToResponse < ActiveRecord::Migration
  def change
    add_column :survey_responses, :photo, :string, {:default => nil}
  end
end
