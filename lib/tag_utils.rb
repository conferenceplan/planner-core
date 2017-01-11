module TagUtils
  # def getContexts
    # taggings = ActsAsTaggableOn::Tagging.all,
                  # :select => "DISTINCT(context)",
                  # :conditions => "taggable_type like 'SurveyRespondent'"
#                   
    # tagContexts = Array.new
# 
    # # for each context get the set of tags (sorted), and add them to the collection for display on the page
    # taggings.each do |tagging|
      # tagContexts << tagging.context
    # end
#     
    # return tagContexts
  # end  
# 
  # def copyTags(from, to)
    # # copy the tags from the respondent to the person
    # tagContexts = getContexts
#     
    # tagContexts.each do |context|
      # tags = from.tag_list_on(context)
      # tagstr = tags * ","
      # if tags
        # to.set_tag_list_on(context, tagstr)
      # end
    # end
  # end
# 
  # def copyTags(from, to, context)
    # tags = from.tag_list_on(context)
    # tagstr = tags * ","
    # if tags
      # to.set_tag_list_on(context, tagstr)
    # end
  # end

end
