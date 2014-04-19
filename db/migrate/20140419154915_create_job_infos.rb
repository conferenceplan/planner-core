class CreateJobInfos < ActiveRecord::Migration
  def change
    create_table :job_infos do |t|
      t.datetime :last_run
      t.string :job_name

      t.timestamps
    end
  end
end
