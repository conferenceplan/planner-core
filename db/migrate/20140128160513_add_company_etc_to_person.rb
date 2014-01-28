class AddCompanyEtcToPerson < ActiveRecord::Migration
  def change
    add_column :people, :company, :string, { :default => "" }
    add_column :people, :job_title, :string, { :default => "" }
  end
end
