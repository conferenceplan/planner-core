require 'test_helper'

class Items::ItemDetailsCellTest < Cell::TestCase
  test "templates" do
    invoke :templates
    assert_select "p"
  end
  
  test "javascript" do
    invoke :javascript
    assert_select "p"
  end
  
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
