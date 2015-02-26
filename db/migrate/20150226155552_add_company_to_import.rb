class AddCompanyToImport < ActiveRecord::Migration
  def change
    add_column :import_mappings, :job_title, :integer, {:default => -1}
    add_column :import_mappings, :company, :integer, {:default => -1}
  end
end
