require 'test_helper'

class TopMenuCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
