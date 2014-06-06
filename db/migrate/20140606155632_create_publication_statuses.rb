class CreatePublicationStatuses < ActiveRecord::Migration
  def change
    create_table :publication_statuses do |t|
      t.string :status
      t.datetime :submit_time

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
