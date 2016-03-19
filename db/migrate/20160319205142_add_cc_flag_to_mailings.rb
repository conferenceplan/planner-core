class AddCcFlagToMailings < ActiveRecord::Migration
  def change
    add_column :mailings, :cc_all, :boolean, {:default => false}
  end
end
