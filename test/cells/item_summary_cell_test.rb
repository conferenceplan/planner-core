require 'test_helper'

class ItemSummaryCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
