class AddInfoToSiteConfig < ActiveRecord::Migration
  def change
    add_column :site_configs, :name,            :string,    :default => ""
    add_column :site_configs, :time_zone,       :string,    :default => "Eastern Time (US & Canada)"
    add_column :site_configs, :start_date,      :datetime,  :default => nil
    add_column :site_configs, :number_of_days,  :integer,   :default => 1
  end
end
