#
require 'update_from_survey_job'

class Tasks::UpdateExclusionsController < ApplicationController
  def index
    job = UpdateFromSurveyJob.new
    
    # Create a job that will be run seperately
    Delayed::Job.enqueue job

    render status: :ok, text: {}.to_json
  end
end
