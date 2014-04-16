class SurveyFormat < ActiveRecord::Base
  # TODO - cleanup unused params
  attr_accessible :lock_version, :help, :style, :description_style, :answer_style, :question_style,
                  :formatable_id, :formatable_type
  
  belongs_to :formatable, :polymorphic => true
end
