require 'test_helper'

class MailTemplatesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mail_templates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mail_template" do
    assert_difference('MailTemplate.count') do
      post :create, :mail_template => { }
    end

    assert_redirected_to mail_template_path(assigns(:mail_template))
  end

  test "should show mail_template" do
    get :show, :id => mail_templates(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mail_templates(:one).to_param
    assert_response :success
  end

  test "should update mail_template" do
    put :update, :id => mail_templates(:one).to_param, :mail_template => { }
    assert_redirected_to mail_template_path(assigns(:mail_template))
  end

  test "should destroy mail_template" do
    assert_difference('MailTemplate.count', -1) do
      delete :destroy, :id => mail_templates(:one).to_param
    end

    assert_redirected_to mail_templates_path
  end
end
