require 'test_helper'

class TagContextsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tag_contexts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tag_context" do
    assert_difference('TagContext.count') do
      post :create, :tag_context => { }
    end

    assert_redirected_to tag_context_path(assigns(:tag_context))
  end

  test "should show tag_context" do
    get :show, :id => tag_contexts(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => tag_contexts(:one).to_param
    assert_response :success
  end

  test "should update tag_context" do
    put :update, :id => tag_contexts(:one).to_param, :tag_context => { }
    assert_redirected_to tag_context_path(assigns(:tag_context))
  end

  test "should destroy tag_context" do
    assert_difference('TagContext.count', -1) do
      delete :destroy, :id => tag_contexts(:one).to_param
    end

    assert_redirected_to tag_contexts_path
  end
end
