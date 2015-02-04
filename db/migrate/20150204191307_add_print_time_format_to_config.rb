class AddPrintTimeFormatToConfig < ActiveRecord::Migration
  def change
    add_column :site_configs, :print_time_format, :string, { :default => '24' }
  end
end
