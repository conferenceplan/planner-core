class AlterPendingImport < ActiveRecord::Migration
  def up
    execute "ALTER TABLE `pending_import_people` modify column `country` varchar(255)"

    # add_column :pending_import_people, :person_id, :integer
  end

  def down
    # remove_column :pending_import_people, :person_id
  end
end
