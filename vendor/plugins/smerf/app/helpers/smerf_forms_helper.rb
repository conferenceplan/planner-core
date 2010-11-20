require "smerf_system_helpers"

# This module contains all the helper methods used by the smerf form views.
module SmerfFormsHelper
  include SmerfSystemHelpers

  # This method creates a formatted error message that is then 
  # displayed on the smerf form page to inform the user of any errors.
  # 
  # CSS identifier: <tt>smerfFormError</tt>
  #
  def get_error_messages(errors)
    if (errors and !errors.empty?())
      header_message = 
        "#{pluralize(errors.size(), 'error')} prevented #{@smerfform.name} from being saved"
      error_messages = ""
#      errors.each do |error| 
#        # Check if question text available as some questions may have no text, 
#        # e.g. sub questions. If this happens we check all parent objects to see
#        # if the question text is available until text found or no more parents
#        question = (error[1]["question"] and !error[1]["question"].blank?()) ? error[1]["question"] : "" #find_question_text(error[0])        
##        # Format error message
##        error[1]["msg"].each do |error_msg|
##          error_messages += content_tag(:li, "#{question}: #{error_msg}") 
##        end
#      end
      content_tag(:div,
        content_tag(:h2, header_message),
#        <<
#          content_tag(:p, 'There were problems with the questions in the form')
#          <<
#          content_tag(:ul, error_messages),
        :class => "smerfFormError")
    else
      ''
    end
  end
  
  # This method creates a formatted notice message that is then 
  # displayed on the smerf form. The notice message is retrieved
  # from the flash[:notice].
  # 
  # CSS identifier: <tt>smerfFormNotice</tt>
  #
  def get_notice_messages
    if flash[:notice]
      content_tag(:div, content_tag(:p, flash[:notice]), :class => "smerfFormNotice")
    end
  end  

  # This method retrieves and formats the form title.
  # 
  # CSS identifier: <tt>h2</tt>
  #
  def smerf_title
    if !@smerfform.form.name.blank?
      content_tag(:h2, @smerfform.form.name)
    end
  end
  
  # This method retrieves and formats the form welcome message.
  # 
  # CSS identifier: <tt>formWelcome</tt>
  #
  def smerf_welcome
    if !@smerfform.form.welcome.blank?
      html = ""
      html = @respondent.first_name + " " + @respondent.last_name if @respondent
      html = "<b>Welcome " + html + " </b>"
      content_tag(:div, html + content_tag(:p, @smerfform.form.welcome), :class => "smerfWelcome")
    end
  end
  
  # This method retrieves and formats the form thank you message.
  # 
  # CSS identifier: <tt>smerfThankyou</tt>
  #
  def smerf_thank_you
    if !@smerfform.form.thank_you.blank?
      content_tag(:div, content_tag(:p, @smerfform.form.thank_you), :class => "smerfThankyou")
    end
  end
  
  # This method retrieves and formats the group name of the group
  # passed in as a parameter.
  # 
  # CSS identifier: <tt>smerfGroup</tt>
  #
  def smerf_group_name(group)
    if !group.name.blank?
      content_tag(:h3, group.name)
    end
  end
   
  # This method retrieves and formats the group description of the group
  # passed in as a parameter.
  # 
  # CSS identifier: <tt>smerfGroup</tt>
  #
  def smerf_group_description(group)
    if !group.description.blank?
      content_tag(:div, group.description, :class => group.description_style) 
#      content_tag(:div, content_tag(:p, group.description), :class => "") # TODO
    end
  end
 
  # This method retrieves all the groups defined in the form.
  # 
  def smerf_get_groups
    @smerfform.form.groups
  end
 
  # This method retrieves all the questions defined for the group
  # passed in as a parameter.
  # 
  def smerf_get_group_questions(group)
    group.questions 
  end
  
  # This method formats the question, and any answers and subquestions
  # defined for it. The method takes a question object(SmerfQuestion)
  # and a level indicator as parameters. The level indicator tells us if
  # a question is a subquestion or not (level > 1).
  # 
  # The question type is checked to see how is should be formatted, currently 
  # the following formats are supported:
  # 
  # * Multiple choice (checkbox)
  # * Single choice (radio)
  # * Text field (large amount of text)
  # * Text box (small amount of text) 
  # 
  # CSS identifiers: 
  #   smerfQuestionHeader
  #   smerfQuestion
  #   smerfSubquestion
  #   smerfQuestionError
  #   smerfInstruction
  # 
  def smerf_group_question(question, level = 1, add_index = "")
    contents = ""
    answered = false
    # Format question header 
    contents += content_tag(:div, content_tag(:p, question.header), 
      :class => "smerfQuestionHeader") if (question.header and !question.header.blank?) 
    # Format question
    classStr = (level <= 1) ? "smerfQuestion" : "smerfSubquestion"
    classStr += " " + question.question_style if question.question_style
    if question.validation and question.validation.include? "mandatory"
      classStr += " mandatory"
    end
    helpLink = "<a title='"+question.help+"'>"+image_tag("smerf_help.gif", :alt => "Help")+"</a>" if (!question.help.blank?)
    
    if (question.question and !question.question.blank?)
      contents += content_tag(:div, 
          question.question + (helpLink ? " " + helpLink : ""),
        :id => question.question_id,
        :class => classStr) 
    else
      contents += helpLink ? " " + helpLink : ""
    end
    # Format error
    contents += content_tag(:div, 
      content_tag(:p, "#{image_tag("smerf_error.gif", :alt => "Error")} #{@errors["#{question.item_id}"]["msg"]}"), 
      :class => "smerfQuestionError") if (@errors and @errors.has_key?("#{question.item_id}"))    

    # Format help   
#    contents += "<a title='"+question.help+"'>"+image_tag("smerf_help.gif", :alt => "Help")+"</a>" if (!question.help.blank?)    
   
#  * Put in some HTML like the following:
# * div.tag
# * <div class='tag'> 
# * <div id='context' style='display:none'>contextname</div>
# * <div id='respondent' style='display:none'>id</div>
# * <textarea rows="5" name="responses[g3q7t1]" id="responses_g3q7t1" cols="30" class='tag'></textarea>
# * </div>
    if (question.tags)
      contents += "<div class='taggable grid_10'><div id='context' style='display:none'>"+question.tags+"</div>"
    end
    # Check the type and format appropriatly
    case question.type
    when 'multiplechoice'
      result = get_multiplechoice(question, level)
      contents += result[:content]
      answered = result[:answer]
    when 'textbox'
      result = get_textbox(question, level)
      contents += result[:content]
      answered = result[:answer]
    when 'textfield'
      result = get_textfield(question, level)
      contents += result[:content]
      answered = result[:answer]
    when 'singlechoice'
      result = get_singlechoice(question, level)
      contents += result[:content]
      answered = result[:answer]
    when 'selectionbox'
      result = get_selectionbox(question, level)
      contents += result[:content]
      answered = result[:answer]
    else  
      raise("Unknown question type for question: #{question.question}")
    end

    if (question.tags)
      contents += "</div>"
    end

    # question style needs to be modified if the add index is not empty...
    # hidden so that this can be revealed by JS and change the code logically
#    questionClass = (!question.style.blank?) ? question.style : (level <= 1) ? "smerfQuestionArea" : "smerfSubquestionArea" 

    questionClass = (!question.style.blank?) ? " " + question.style : ""
    contentId = nil
    contentId = add_index if(!add_index.empty?)
    questionClass += " toggle" if((!add_index.empty?) and (!result[:answer]) )
    contents = content_tag(:div, contents, :class => questionClass, :id => contentId)
 
    # only put in the add if the next element is empty...
    additional_content = ""
    hide_link = false
    if (question.additional and add_index.empty? )
      # for each of the additional we want to create a new version of the same question
      1.upto(question.additional) { |i|
        dup_question = question.clone
        dup_question.additional = 0
        dup_question.code += "-" + i.to_s
        change_question_code(dup_question, "-" + i.to_s)
        # need to go through the nested questions and change their codes as well
        additional_content = smerf_group_question(dup_question, level, dup_question.code)
        
        if (!additional_content[:answered])
          if (hide_link)
            contents += "<a class='toggleLink toggle grid_1 prefix_5'>add another</a>" if((!add_index.empty?)or question.additional)
          else
            contents += "<a class='toggleLink grid_1 prefix_5'>add another</a>" if((!add_index.empty?)or question.additional)
          end
          hide_link = true
        end
        contents += additional_content[:content]
     }
    end

    return { :content => contents, :answered => answered }
  end
  
  private
  
    # recusively set the new code for the duplicated question's
    # sub questions
    def change_question_code(question, code)
      question.answers.each do |answer|
        if (answer.respond_to?("subquestions") and answer.subquestions and answer.subquestions.size > 0)
        answer.subquestions.each {|subquestion| 
           subquestion.code += code
           change_question_code(subquestion, code)
          }
        end
      end
    end
  
    # Some answers to questions may have further questions, here we 
    # process these sub questions.
    #
    def process_sub_questions(answer, level)
      # Process any answer sub quesions by recursivly calling this function
      sq_contents = ""
      if (answer.respond_to?("subquestions") and 
        answer.subquestions and answer.subquestions.size > 0)
        answer.subquestions.each {|subquestion| sq_contents += 
          smerf_group_question(subquestion, level+1)[:content]}
        # Indent question
#        sq_contents = "<div style=\"margin-left: #{level * 25}px;\">" + sq_contents + '</div>'       
      end
      return sq_contents
    end

    # Format multiple choice question
    #
    def get_multiplechoice(question, level)
      contents = ""
      answered = false
      question.answers.each do |answer|
        # Get the user input if available
        user_answer = nil
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}") and
          @responses["#{question.code}"].has_key?("#{answer.code}"))
          user_answer = @responses["#{question.code}"]["#{answer.code}"]
          answered = true
        end
        # Note we wrap the form element in a label element, this allows the input
        # field to be selected by selecting the label, we could otherwise use a 
        # <lable for="....">...</label> construct to do the same
        style = "checkbox"
        style += " " + question.answer_style if question.answer_style
        html = '<label>' + check_box_tag("responses[#{question.code}][#{answer.code}]", answer.code, 
          # If user responded to the question and the value is the same as the question 
          # value then tick this checkbox
          ((user_answer and !user_answer.blank?() and user_answer.to_s() == answer.code.to_s()) or   
          # If this is a new record and no responses have been entered, i.e. this is the
          # first time the new record form is displayed set on if default 
          ((!@responses or @responses.empty?()) and params['action'] == 'show' and
          answer.default.upcase == 'Y'))) + 
          "#{answer.answer}</label>\n"
#        helpLink = "<a title='"+answer.help+"'>"+image_tag("smerf_help.gif", :alt => "Help")+"</a>" if (answer.help.blank?)
#        html += helpLink ? " " + helpLink : "AA"
        contents += content_tag(:div, html, :class => style, :id => question.answer_id)
        # Process any sub questions this answer may have
        if (question.subfirst)
          contents = process_sub_questions(answer, level) + contents
        else
          contents += process_sub_questions(answer, level)
        end
      end
      # Process error messages if they exist
      #wrap_error(contents, (@errors and @errors.has_key?("#{question.code}")))
      #contents = content_tag(:div, contents, :class => "questionWithErrors") if (@errors and @errors.has_key?("#{question.code}"))
      return { :content => contents, :answer => answered }
    end

    # Format text box question
    #
    def get_textbox(question, level)
      # Get the user input if available
      user_answer = nil
      answered = false
      if (@responses and !@responses.empty?() and 
        @responses.has_key?("#{question.code}"))
        user_answer = @responses["#{question.code}"]
        answered = (user_answer and !user_answer.blank?())
      end
      style = ""
      style += question.tags if question.tags
      style += " " + question.answer_style if question.answer_style
      contents = text_area_tag("responses[#{question.code}]",    
        # Set value to user response if available
        if (answered)
          user_answer
        else
          nil
        end,
        :size => (!question.textbox_size.blank?) ? question.textbox_size : "30x5",
        :class => style, :id => question.answer_id )
      if (question.tags)
        contents += '<div class="cloud"></div>'
      end

      return { :content => contents, :answer => answered }
    end

    # Format text field question
    #
    def get_textfield(question, level)
      # Get the user input if available
      answered = false
      user_answer = nil
      if (@responses and !@responses.empty?() and 
        @responses.has_key?("#{question.code}"))
        user_answer = @responses["#{question.code}"]
        answered = (user_answer and !user_answer.blank?())
      end
      style = "text"
      style += " " + question.answer_style if question.answer_style
      contents = text_field_tag("responses[#{question.code}]", 
        # Set value to user responses if available
        if (answered)
          user_answer
        else
          nil
        end, 
        :size => (!question.textfield_size.blank?) ? question.textfield_size : "30",
        :class => question.tags, :id => question.answer_id, :title => question.title)
      contents = content_tag(:div, contents, :class => style)

      if (question.tags)
        contents += '<div class="cloud grid_12"></div>'
      end
      
      return { :content => contents, :answer => answered }
    end

    # Format single choice question
    #
    def get_singlechoice(question, level)
      contents = ""
      answered = false
      question.answers.each do |answer|
        # Get the user input_objects if available
        user_answer = nil
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}"))
          user_answer = @responses["#{question.code}"]
          answered = true
        end
        answerstyle = answer.style if answer.style
        answerid = answer.answer_id if answer.answer_id
        # Note we wrap the form element in a label element, this allows the input
        # field to be selected by selecting the label, we could otherwise use a 
        # <lable for="....">...</label> construct to do the same
        html = '<label>' + radio_button_tag("responses[#{question.code}]", answer.code,
          # If user responses then set on if answer available
          ((user_answer and !user_answer.blank?() and user_answer.to_s() == answer.code.to_s()) or   
          # If this is a new record and no response have been entered, i.e. this is the
          # first time the new record form is displayed set on if default 
          ((!@responses or @responses.empty?()) and params['action'] == 'show' and
          answer.default.upcase == 'Y')),
          :class => answerstyle,
          :id => answerid
          ) + 
          "#{answer.answer}</label>\n"
        style = "radiobutton"
        style += " " + question.answer_style if question.answer_style
        contents += content_tag(:div, html, :class => style, :id => question.answer_id)
        # Process any sub questions this answer may have
        if (question.subfirst)
          contents = process_sub_questions(answer, level) + contents
        else
          contents += process_sub_questions(answer, level)
        end
      end
#      return contents
      return { :content => contents, :answer => answered }
    end
 
    # Format drop down box(select) question
    #
    def get_selectionbox(question, level)
      # Note: This question type can not have subquestions      
      contents = ""
      answered = false
      answers = "\n"
      question.answers.each do |answer|
        # Get the user input if available
        user_answer = nil
        if (@responses and !@responses.empty?() and 
          @responses.has_key?("#{question.code}") and
          @responses["#{question.code}"].include?("#{answer.code}"))
          user_answer = answer.code
          answered = true
        end
        # Format answers
        answers += '<option ' + 
          # If user responses then set on if answer available
          (((user_answer and !user_answer.blank?() and user_answer.to_s() == answer.code.to_s()) or   
          # If this is a new record and no response have been entered, i.e. this is the
          # first time the new record form is displayed set on if default 
          ((!@responses or @responses.empty?() or !@responses.has_key?("#{question.code}")) and params['action'] == 'show' and
          answer.default.upcase == 'Y')) ?  ' selected="selected"' : '') 
        answers += ' value="' + answer.code.to_s() + '">' +       
          answer.answer + "</option>\n"
      end
        
      # Note the additional [] in the select_tag name, without this we only get 
      # one choice in params, adding the [] gets all choices as an array
      style = "select"
      style += " " + question.answer_style if question.answer_style
      html = "\n" + select_tag("responses[#{question.code}][]", answers, :multiple => 
        # Check if multiple choice
        (question.selectionbox_multiplechoice and 
        !question.selectionbox_multiplechoice.blank?() and
        question.selectionbox_multiplechoice.upcase == 'Y'))
      contents += content_tag(:div, html, :class => style, :id => question.answer_id)
      
#      return contents
      return { :content => contents, :answer => answered }
    end
   
    # Some questions/sub questions may not actually have any question text,
    # e.g. sub question. When an error occurs we want to display the text
    # of the question where the problem has occurred so this function will
    # try and find the question this object belongs to and display the question
    # text in the error message
    #
    def find_question_text(item_id)
      text = ""
      
      # Retrieve the object with the supplied ident         
      smerf_object = smerf_get_object(item_id, @smerfform.form)
      
      # Check if  we have reached the root level, if so return
      # an empty string
      return text if (smerf_object.parent_id == @smerfform.code)

      # Retrieve the owner object and see if it is a question, if not
      # we move up the object tree until a question is found with 
      # question text or we reach the root level
      smerf_owner_object = smerf_get_owner_object(smerf_object, @smerfform.form)      
      if (!smerf_owner_object.is_a?(SmerfQuestion) or
        smerf_owner_object.question.blank?())
        # Not a question, or no text for this question, recursivly call this function
        # moving up the tree until we reach the root level or a question with text
        # is found
        text = find_question_text(smerf_owner_object.item_id)
      else
        text = smerf_owner_object.question
      end
      
      return text.strip()
    end
end
