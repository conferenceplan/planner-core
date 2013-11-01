#
#
#
class PublisherController < PlannerController
  include TagUtils
  
  cache_sweeper :program_sweeper, :only => [ :publish ]
  
  def index
    @publicationInfo = PublicationDate.last
  end
  
  # publish the selected program items
  def publish
    pubjob = PublishJob.new
    if ENV['SENDGRID_DOMAIN'] == 'heroku.com'
      # if we are on Heroku then the job can not be run in background with the free account
      pubjob.perform
      @publicationInfo = PublicationDate.last
    else
      # Create a job that will be run seperately
      Delayed::Job.enqueue pubjob
    end

    if (cache_configured?)
      # Rails.cache.clear # make sure that the mem cache is flushed
    end
        
    render :layout => 'content'
  end
  
  def review
    pubjob = PublishJob.new
    @candidateNewItems = pubjob.getNewProgramItems() # copy all unpublished programme items
    @candidateModifiedItems = pubjob.getModifiedProgramItems() # copy all programme items that have changes made (room assignment, added person, details etc)
    @candidateRemovedItems = []
    @candidateRemovedItems.concat(pubjob.getRemovedProgramItems()) # remove all items that should no longer be published
    @candidateRemovedItems.concat(pubjob.getUnpublishedItems()) # remove all items that should no longer be published
  end
  
  # list all the published programme items
  def list
  end
  
end
