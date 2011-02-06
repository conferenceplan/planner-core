class MenuAddSurveyreview < ActiveRecord::Migration
  def self.up
#http://localhost:3000/survey_respondents/reviews
    menu = MenuItem.all(:conditions => { :name => "Participants" } ).first
    MenuItem.create( :name => "Review Surveys", :path => "/survey_respondents/reviews", :menu_item => menu)
  end

  def self.down
  end
end
