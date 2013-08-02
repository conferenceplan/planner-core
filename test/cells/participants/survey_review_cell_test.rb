require 'test_helper'

class Participants::SurveyReviewCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
