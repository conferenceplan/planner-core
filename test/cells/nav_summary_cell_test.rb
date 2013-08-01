require 'test_helper'

class NavSummaryCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
