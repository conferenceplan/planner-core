require 'test_helper'

class Venues::ManageCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
