module PlannerHelper

  def baseUri
    '/' + I18n.locale.to_s
  end

  def baseUri_no_lang
    ''
  end
  
  def extra_navigation
    ''
  end

  def extra_participant_tabs
    ''
  end

  def extra_item_tabs
    ''
  end

end
