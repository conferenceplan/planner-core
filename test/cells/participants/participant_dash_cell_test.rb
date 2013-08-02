require 'test_helper'

class Participants::ParticipantDashCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
