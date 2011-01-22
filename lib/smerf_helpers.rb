require 'smerf_system_helpers'

# This module contains helper methods used by smerf, in particular
# custom user defined validation methods that are used to validate user responses.
# 
# All validation methods need to take three parameters:
# question:: The SmerfQuestion object to be validated
# responses:: Hash containing user responses keyed using the question code
# form:: Hash that contains all form objects including groups, questions and answers
# 
# The method needs to return an empty string or nil if no errors or 
# if there is an error then an error message describing the error should be returned.
# 
# Within the form definition file you specify if a validation is required
# on a question by specifying which methods within this module
# should be called to perform that validation, e.g.
# 
# specify_your_age:
#   code: g1q1
#   type: singlechoice
#   sort_order: 1
#   question: | Specify your ages  
#   help: | Select the <b>one</b> that apply 
#   validation: validation_mandatory
# 
# Multiple validation methods can be specified by comma separating each method name,
# there are also some standard validation methods supplied with smerf that can be used
# as well as your own defined within this module.                                          
#

module SmerfHelpers

  # TODO - add helpers to validate email and phone numbers
  
  def add_tags(question, responses, form)
    # Add tags to the respondent from a tag field
    answer = smerf_get_question_answer(question, responses)
    # get the tag context from the question
    context = question.tags
    
    if (answer)
      answer = answer.split(' ').map {|w| 
        w[0] = w[0].chr.upcase
        w }.join(' ')
      smerf_set_question_answer(question, responses, answer)
    else
      answer = ''
    end
    
    SurveyRespondent.transaction(:requires_new => true) do
      respondent = SurveyRespondent.find(self.current_user)
      
      if (respondent)
        respondent.set_tag_list_on(context, answer) # set the tag list on the respondent for the context
        
        if !respondent.save
          return "Unable to associate tag"
        end
      end
    end
    
    return nil
  end

  # Example validation method for "How many years have you worked in the industry"
  # it uses a regex to make sure 0-99 years specified.
  #
  def validate_years(question, responses, form)
    # Validate entry and make sure years are numeric and between 0-99
    answer = smerf_get_question_answer(question, responses)    
    if (answer)
      # Expression will return nil if regex fail, also check charcters
      # after the match to determine if > 2 numbers specified
      res = ("#{answer}" =~ /\d{1,2}/)      
      return "Years must be between 0 and 99" if (!res or $'.length() > 0)      
    end
    
    return nil
  end
  
  #
  #
  #
  def validate_time_entry(question, responses, form)
    answer = smerf_get_question_answer(question, responses)
    answer_object = smerf_get_owner_object(question, form)
    answer_code = answer_object.code
    question_object = smerf_get_owner_object(answer_object, form)
    
    if smerf_question_has_answer?(question_object, responses, answer_code)
      if (answer)
        # If the person has not selected that they are unsure about their times then they need
        # to have set the time...
        if !responses["g6s1q1"]
          if answer[0] == "0" # if the time is 0 then the user has not selected an actual time
            return "No time selected for '#{question.question.strip}''"
          end
        end
      end
    end
    
    return nil
  end
  
end
