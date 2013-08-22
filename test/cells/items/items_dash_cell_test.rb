require 'test_helper'

class Items::ItemsDashCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
