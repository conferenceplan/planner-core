require 'test_helper'

class Items::ManageCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
