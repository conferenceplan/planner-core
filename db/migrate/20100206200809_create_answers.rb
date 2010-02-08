#
# The survey can contain many answers. The answers are answers to questions, such as "what would you like to present?"
# This provides a more flexible mechanism instead of having specific columns in the Person or Registration details with
# the information.
#
# NOTE: we may want to have types of answers...
#
class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.references :Survey
      
      t.string :question
      t.text :reply

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :answers
  end
end
