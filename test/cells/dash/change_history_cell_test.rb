require 'test_helper'

class Dash::ChangeHistoryCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  
  test "javascript" do
    invoke :javascript
    assert_select "p"
  end
  
  test "template" do
    invoke :template
    assert_select "p"
  end
  

end
