#
# For tags associated with Survey respondents
#
# TODO: this should only be accessed via authenticated respondent (for update)
#
class SurveyRespondents::TagsController < ApplicationController
# TODO: how do we get the id of the respondent, how do I find the current
# survey respondent?
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

# TODO - change so that the tags are consistent from a case perspective
    respondent.set_tag_list_on(tag_context, tag_list) # set the tag list on the respondent for the context
    
    respondent.save
    
    render :layout => 'content'
  end

  # get the tags for a specific tag list
  def alltags
    tag_context = params[:context] # tag context
    @tags = SurveyRespondent.tag_counts_on(tag_context)
    
    respond_to do |format|
      format.xml
    end
  end
  
  # get the tag cloud for a specific tag list
  def cloud
    tag_context = params[:context] # tag context
    target = params[:target] # tag context
    @tags = SurveyRespondent.tag_counts_on(tag_context).sort { |x, y| x.name.downcase <=> y.name.downcase }
    
    if target == 'selection'
      render 'selection', :layout => 'content'
    else  
      render :layout => 'content'
    end
  end
end

# TODO : use act as taggable to create dynamic tag contexts. These can be tag contexts for a given
# name.
# @user = User.new(:name => "Bobby")
#    @user.set_tag_list_on(:customs, "same, as, tag, list")
#    @user.tag_list_on(:customs) # => ["same","as","tag","list"]
#    @user.save
#    @user.tags_on(:customs) # => [<Tag name='same'>,...]
#    @user.tag_counts_on(:customs)
#    User.tagged_with("same", :on => :customs) # => [@user]
#
