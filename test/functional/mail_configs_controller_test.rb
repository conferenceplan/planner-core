require 'test_helper'

class MailConfigsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mail_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mail_config" do
    assert_difference('MailConfig.count') do
      post :create, :mail_config => { }
    end

    assert_redirected_to mail_config_path(assigns(:mail_config))
  end

  test "should show mail_config" do
    get :show, :id => mail_configs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mail_configs(:one).to_param
    assert_response :success
  end

  test "should update mail_config" do
    put :update, :id => mail_configs(:one).to_param, :mail_config => { }
    assert_redirected_to mail_config_path(assigns(:mail_config))
  end

  test "should destroy mail_config" do
    assert_difference('MailConfig.count', -1) do
      delete :destroy, :id => mail_configs(:one).to_param
    end

    assert_redirected_to mail_configs_path
  end
end
