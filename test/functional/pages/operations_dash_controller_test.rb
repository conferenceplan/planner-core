require 'test_helper'

class Pages::OperationsDashControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
