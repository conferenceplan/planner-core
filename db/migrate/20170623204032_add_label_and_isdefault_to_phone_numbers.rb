class AddLabelAndIsdefaultToPhoneNumbers < ActiveRecord::Migration
  def change
    add_column :phone_numbers, :label, :string
    add_column :phone_numbers, :isdefault, :boolean, nil: false, default: false
  end
end
