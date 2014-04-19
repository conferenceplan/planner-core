class SurveyFormat < ActiveRecord::Base
  # TODO - cleanup unused params
  attr_accessible :lock_version, :help, :style, :description_style, :answer_style, :question_style,
                  :formatable_id, :formatable_type, :created_at, :help1, :help2, :help3, :help4, :help5, :help6, :id, :updated_at
  
  belongs_to :formatable, :polymorphic => true
end
