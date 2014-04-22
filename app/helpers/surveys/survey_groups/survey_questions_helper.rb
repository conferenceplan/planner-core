module Surveys::SurveyGroups::SurveyQuestionsHelper

  def getDayConflictCollection()
     
      dayCollection = (0..((SiteConfig.first.number_of_days).to_i-1)).to_a.collect{ |r| [(Time.zone.parse(SiteConfig.first.start_date.to_s) + r.days).strftime('%A'), r]}
      allArray = ["All", (SiteConfig.first.number_of_days).to_i]
      dayCollection[(SiteConfig.first.number_of_days).to_i] = allArray
      return dayCollection
  end

end
