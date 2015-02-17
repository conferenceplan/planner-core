require 'test_helper'

class Admin::SystemConfigsCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  
  test "render" do
    invoke :render
    assert_select "p"
  end
  
  test "templates" do
    invoke :templates
    assert_select "p"
  end
  

end
