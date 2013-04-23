#
#
#
class SurveyRespondents::TagsAdminController < PlannerController
  # The start page, we start with a hash of the tag contexts and their associated tags
  def index
    taggings = ActsAsTaggableOn::Tagging.find :all,
                  :select => "DISTINCT(context)",
                  :conditions => "taggable_type like 'SurveyRespondent'"
                  
    @tagContexts = Array.new

    # for each context get the set of tags (sorted), and add them to the collection for display on the page
    taggings.each do |tagging|
      @tagContexts << tagging.context
    end
  end

  #
  def update
    # First get the operation
    operation = params[:tag][:operation]
    destination = params[:tag][:destination]
    old_value = params[:original_tag].strip
    new_value = params[:new_tag].strip
    context = params[:context]
    
    new_value = toUpperCase(new_value)

    # Then depending on the op do an edit/move/delete
    case operation
      when 'edit' then edit(context, old_value, new_value)
      when 'move' then move(context, old_value, destination)
      when 'delete' then delete(context, old_value)
    end
    
    render :layout => 'content'
  end
  
  def fix
    taggings = ActsAsTaggableOn::Tagging.find :all,
                  :select => "DISTINCT(context)",
                  :conditions => "taggable_type like 'SurveyRespondent'"
                  
    tcs = Array.new
    # for each context get the set of tags (sorted), and add them to the collection for display on the page
    taggings.each do |tagging|
      tcs << tagging.context
    end
    
    # go through all the respondents and fix the tags....
    # respondents = SurveyRespondent.all
    # respondents.each do |respondent|
      # tcs.each do |context|
        # tags = respondent.tag_counts_on(context)
        # if (respondent.person)
          # respondent.person.set_tag_list_on(context, tags )
          # respondent.person.save
        # end
      # end
    # end

    tcs.each do |context|
      responses = SurveyResponse.all :include => :survey_question, :conditions => {:survey_questions => {:tags_label => context}}
      responses.each do |response|
        tags = response.survey_respondent_detail.survey_respondent.tag_counts_on(context)
        new_tags = tags.collect {|tag| tag.name }
        response.response = new_tags.join(",")
        response.save
      end
    end
    
  end

private

  def toUpperCase(str)
    str = str.split(' ').map {|w|
      w[0] = w[0].chr.upcase
      w }.join(' ')
    return str;  
  end

  def edit(context, old_value, new_value)
    respondents = SurveyRespondent.tagged_with(old_value, :on => context)
    # questionId = @tagContexts[context]
    
    respondents.each do |respondent|
      tags = respondent.tag_counts_on(context)
    
      new_tags = tags.collect {|tag| (tag.name == old_value) ? new_value : tag.name }
      
      respondent.set_tag_list_on(context, new_tags.join(",") )
      respondent.save
      
      if (respondent.person)
        respondent.person.set_tag_list_on(context, new_tags.join(",") )
        respondent.person.save
      end
    end
    
    responses = SurveyResponse.all( :conditions => ["response like ? and survey_question_id in (SELECT id FROM survey_questions where tags_label = ?)", '%'+ old_value +'%', context])
    responses.each do |response|
      response.response = response.response.sub(Regexp.new(old_value),new_value)
      response.save
    end

  end
  
  def move(context, old_value, destination)
    respondents = SurveyRespondent.tagged_with(old_value, :on => context)
    
    respondents.each do |respondent|
      tags = respondent.tag_counts_on(context)
    
      new_tags = tags.collect {|tag| tag.name}
      new_tags.delete(old_value)
      
      respondent.set_tag_list_on(context, new_tags.join(",") )
      
      dest = respondent.tag_counts_on(destination)
      dest_tags = dest.collect {|tag| tag.name}
      dest_tags.push(old_value)

      respondent.set_tag_list_on(destination, dest_tags.join(",") )

      respondent.save
      
      if (respondent.person)
        respondent.person.set_tag_list_on(context, new_tags.join(",") )
        respondent.person.set_tag_list_on(destination, dest_tags.join(",") )
        respondent.person.save
      end
    end
    
    # delete it
    responses = SurveyResponse.all( :conditions => ["response like ? and survey_question_id in (SELECT id FROM survey_questions where tags_label = ?)", '%'+ old_value +'%', context])
    responses.each do |response|
      str = response.response
      str = str.split(',').collect { |val| (val.strip.downcase == old_value.downcase) ? nil : (val.strip == ',' || val.strip == '') ? nil : val.strip}
      response.response = str.compact.join(',')
      response.save
    end
    
    # add to the destination
    responses = SurveyResponse.all( :conditions => ["survey_question_id in (SELECT id FROM survey_questions where tags_label = ?)", destination])
    responses.each do |response|
      str = response.response
      str = str.split(',').collect { |val| (val.strip.downcase == old_value.downcase) ? nil : (val.strip == ',' || val.strip == '') ? nil : val.strip}
      str << old_value
      response.response = str.compact.join(',')
      response.save
    end
  end
  
  def delete(context, old_value)
    respondents = SurveyRespondent.tagged_with(old_value, :on => context)
    # questionId = @tagContexts[context]
    
    respondents.each do |respondent|
      tags = respondent.tag_counts_on(context)
    
      new_tags = tags.collect {|tag| tag.name}
      new_tags.delete(old_value)
      
      respondent.set_tag_list_on(context, new_tags.join(",") )
      respondent.save
      
      if (respondent.person)
        respondent.person.set_tag_list_on(context, new_tags.join(",") )
        respondent.person.save
      end
    end
    
    responses = SurveyResponse.all( :conditions => ["response like ? and survey_question_id in (SELECT id FROM survey_questions where tags_label = ?)", '%'+ old_value +'%', context])
    responses.each do |response|
      str = response.response
      str = str.split(',').collect { |val| (val.strip.downcase == old_value.downcase) ? nil : (val.strip == ',' || val.strip == '') ? nil : val.strip}
      response.response = str.compact.join(',')
      response.save
    end
  end

end
