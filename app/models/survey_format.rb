class SurveyFormat < ActiveRecord::Base
  belongs_to :formatable, :polymorphic => true
end
