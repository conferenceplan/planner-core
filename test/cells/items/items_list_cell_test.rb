require 'test_helper'

class Items::ItemsListCellTest < Cell::TestCase
  test "javascript" do
    invoke :javascript
    assert_select "p"
  end
  
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
