#
require 'exclusion_job'

class Tasks::UpdateExclusionsController < ApplicationController
  def index
    job = ExclusionJob.new
    
    # Create a job that will be run seperately
    Delayed::Job.enqueue job

    render status: :ok, text: {}.to_json
  end
end
