require 'test_helper'

class SurveyReportCellTest < ActionController::TestCase
  include Cells::AssertionsHelper
  
    test "show" do
    html = render_cell(:survey_report, :show)
    #assert_selekt html, "div"
  end
  
  
end