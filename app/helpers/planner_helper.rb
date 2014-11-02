module PlannerHelper

  def baseUri
    '/' + I18n.locale.to_s
  end

  def baseUri_no_lang
    ''
  end

end
