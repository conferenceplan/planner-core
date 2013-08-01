require 'test_helper'

class Config::ItemFormatsCellTest < Cell::TestCase
  test "list" do
    invoke :list
    assert_select "p"
  end
  
  test "edit" do
    invoke :edit
    assert_select "p"
  end
  
  test "create" do
    invoke :create
    assert_select "p"
  end
  

end
