class AddSubjectToMailHistory < ActiveRecord::Migration
  def change
    add_column :mail_histories, :subject, :string
  end
end
