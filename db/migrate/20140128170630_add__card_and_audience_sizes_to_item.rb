class AddCardAndAudienceSizesToItem < ActiveRecord::Migration
  def change
    add_column :programme_items,            :mobile_card_size, :integer, { :default => 1 }
    add_column :programme_items,            :audience_size,    :integer, { null: true }        
    add_column :published_programme_items,  :mobile_card_size, :integer, { :default => 1 }
    add_column :published_programme_items,  :audience_size,    :integer, { null: true }        
  end
end
