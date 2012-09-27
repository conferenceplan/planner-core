class SurveyMechanismCleanup < ActiveRecord::Migration
  def self.up
    remove_column :survey_formats, :textfield_size
    remove_column :survey_formats, :textbox_size
    remove_column :survey_formats, :sort_order

    add_column :survey_questions, :mandatory, :boolean, { :default => false }

    add_column :survey_questions, :text_size, :integer
    add_column :survey_questions, :sort_order, :integer
    add_column :survey_groups, :sort_order, :integer

    remove_column :survey_answers, :code
    remove_column :survey_answers, :answer_id
    add_column :survey_answers, :sort_order, :integer
    add_column :survey_answers, :help, :string, { :default => "" }

    add_column :surveys, :alias, :string, { :default => "" }
    add_column :surveys, :submit_string, :string, { :default => "Save" }

    change_column :surveys, :welcome, :text
    change_column :surveys, :thank_you, :text
    change_column :survey_groups, :description, :text
    change_column :survey_formats, :help, :text
    change_column :survey_responses, :response, :text
		rename_column :survey_responses, :person_id, :survey_respondent_detail_id
  end

  def self.down
		rename_column :survey_responses, :survey_respondent_detail_id, :person_id
    add_column :survey_formats, :textfield_size, :integer
    add_column :survey_formats, :textbox_size, :integer
    add_column :survey_formats, :sort_order, :integer

    remove_column :survey_questions, :mandatory

    remove_column :survey_questions, :text_size
    remove_column :survey_questions, :sort_order
    remove_column :survey_groups, :sort_order

    remove_column :surveys, :alias
    remove_column :surveys, :submit_string

    add_column :survey_answers, :code, :string
    add_column :survey_answers, :answer_id, :string
    remove_column :survey_answers, :sort_order
    remove_column :survey_answers, :help

    change_column :surveys, :welcome, :string
    change_column :surveys, :thank_you, :string
    change_column :survey_groups, :description, :string
    change_column :survey_formats, :help, :string
    change_column :survey_responses, :response, :string
  end
end
