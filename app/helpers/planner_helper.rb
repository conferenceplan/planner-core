module PlannerHelper

  def baseUri
    # TODO - put in locale etc
    '/' + I18n.locale.to_s #+ '/'
  end

end
