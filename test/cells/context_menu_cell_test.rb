require 'test_helper'

class ContextMenuCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
