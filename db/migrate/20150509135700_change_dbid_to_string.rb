class ChangeDbidToString < ActiveRecord::Migration
  def up
    change_column :pending_import_people, :datasource_dbid, :string, {:default => nil}
    change_column :peoplesources, :datasource_dbid, :string, {:default => nil}
  end

  def down
    change_column :pending_import_people, :datasource_dbid, :integer
    change_column :peoplesources, :datasource_dbid, :integer
  end
end
