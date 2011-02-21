require 'test_helper'

class SurveyCopyStatusesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_copy_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_copy_status" do
    assert_difference('SurveyCopyStatus.count') do
      post :create, :survey_copy_status => { }
    end

    assert_redirected_to survey_copy_status_path(assigns(:survey_copy_status))
  end

  test "should show survey_copy_status" do
    get :show, :id => survey_copy_statuses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => survey_copy_statuses(:one).to_param
    assert_response :success
  end

  test "should update survey_copy_status" do
    put :update, :id => survey_copy_statuses(:one).to_param, :survey_copy_status => { }
    assert_redirected_to survey_copy_status_path(assigns(:survey_copy_status))
  end

  test "should destroy survey_copy_status" do
    assert_difference('SurveyCopyStatus.count', -1) do
      delete :destroy, :id => survey_copy_statuses(:one).to_param
    end

    assert_redirected_to survey_copy_statuses_path
  end
end
