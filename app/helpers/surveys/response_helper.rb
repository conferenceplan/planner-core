module Surveys::ResponseHelper
  def get_error_messages(errors)
    if (errors and !errors.empty?())
      header_message = 
        "#{pluralize(errors.size(), 'error')} prevented #{@survey.name} from being saved"
      error_messages = ""
      errors.each do |question, error_msg| 
        error_msg.each do |k,v|
          error_messages += content_tag(:li, "#{k}: #{v}") 
        end
      end
      content_tag(:div,
        content_tag(:h3, header_message) <<
          content_tag(:p, 'There were problems with the following questions:') <<
          content_tag(:ul, error_messages.html_safe ),
        :class => "smerfFormError")
    else
      ''
    end
  end
end
