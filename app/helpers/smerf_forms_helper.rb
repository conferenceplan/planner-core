require "smerf_system_helpers"

# This module contains all the helper methods used by the smerf form views.
module SmerfFormsHelper
  include SmerfSystemHelpers

  # This method retrieves and formats the form welcome message.
  # 
  # CSS identifier: <tt>formWelcome</tt>
  #
  def smerf_welcome
    if !@smerfform.form.welcome.blank?
      html = "<b>Welcome " + @respondent.first_name + " " + @respondent.last_name + " </b>"
      content_tag(:div, html + content_tag(:p, @smerfform.form.welcome), :class => "smerfWelcome")
    end
  end
  
end
