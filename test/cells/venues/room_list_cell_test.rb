require 'test_helper'

class Venues::RoomListCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  
  test "javascript" do
    invoke :javascript
    assert_select "p"
  end
  

end
