require 'test_helper'

class Participants::ParticipantDetailsCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
