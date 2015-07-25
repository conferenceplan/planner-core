#
# For tags associated with Survey respondents
#
# This should only be accessed via authenticated respondent (for updates)
#
class SurveyRespondents::TagsController < ApplicationController

  # get a list of tags for a specific tag list for a specific respondent
  def list
    respondent = SurveyRespondent.find(params[:respondent_id])
    tag_context = params[:context] # tag context
    
    taglist = respondent.tag_list_on(tag_context) # return the list of tags (array)
    
    # render the layout as a list of comma seperated tags
  end

  # Update the tag associated with the specific survey respondent
  # update the tags for a given survey respondent's tag list
  def update
    respondent = SurveyRespondent.find(params[:respondent_id])
    tag_context = params[:context] # tag context
    tag_list = params[:tags] # comma seperated list of tags

    respondent.set_tag_list_on(tag_context, tag_list) # set the tag list on the respondent for the context
    
    respondent.save
    
    render :layout => 'content'
  end

  # get the tags for a specific tag list
  def alltags
    tag_context = params[:context] # tag context
    @tags = TagsService.tag_counts_on(SurveyRespondent, tag_context)
    
    respond_to do |format|
      format.xml
    end
  end
  
  # get the tag cloud for a specific tag list
  def cloud
    tag_context = params[:context] # tag context
    target = params[:target] # tag context
    limit = params[:limit] # if there is a limit then we only report back on the limit number of tags and sort by most popular
    @tags = TagsService.tag_counts_on(SurveyRespondent, tag_context).sort { |x, y| x.name.downcase <=> y.name.downcase }
    
    if limit
      l = limit.to_i
      # We now have a collection of names and count, so sort based on count and limit
      @tags = @tags.sort { |x, y| y.count <=> x.count }
      @tags = @tags[0..(l -1)]
    end
    
    if target == 'selection'
      render 'selection', :layout => 'content'
    else  
      render :layout => 'content'
    end
  end
end

# NOTE : use act as taggable to create dynamic tag contexts. These can be tag contexts for a given
# name.
# @user = User.new(:name => "Bobby")
#    @user.set_tag_list_on(:customs, "same, as, tag, list")
#    @user.tag_list_on(:customs) # => ["same","as","tag","list"]
#    @user.save
#    @user.tags_on(:customs) # => [<Tag name='same'>,...]
#    @user.tag_counts_on(:customs)
#    User.tagged_with("same", :on => :customs) # => [@user]
#
