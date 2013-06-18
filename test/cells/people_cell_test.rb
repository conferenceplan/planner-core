require 'test_helper'

class PeopleCellTest < ActionController::TestCase
  include Cells::AssertionsHelper
  
    test "show" do
    html = render_cell(:people, :show)
    #assert_selekt html, "div"
  end
  
  
end