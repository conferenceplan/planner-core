require 'enum'
require 'phone_types'

class AddPhonetypeEnum < ActiveRecord::Migration
  def self.up
       PhoneTypes.enumeration_model_updates_permitted = true
       PhoneTypes.create(:name => 'Home',:position => 1)
       PhoneTypes.create(:name => 'Mobile',:position => 2)
       PhoneTypes.create(:name => 'Work',:position => 3)
       PhoneTypes.create(:name => 'Fax',:position => 4)
       PhoneTypes.create(:name => 'Other',:position => 5)
  end

  def self.down
  end
end
