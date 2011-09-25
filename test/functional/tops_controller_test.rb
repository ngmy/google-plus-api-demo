require 'test_helper'

class TopsControllerTest < ActionController::TestCase
  setup do
    @top = tops(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tops)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create top" do
    assert_difference('Top.count') do
      post :create, top: @top.attributes
    end

    assert_redirected_to top_path(assigns(:top))
  end

  test "should show top" do
    get :show, id: @top.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @top.to_param
    assert_response :success
  end

  test "should update top" do
    put :update, id: @top.to_param, top: @top.attributes
    assert_redirected_to top_path(assigns(:top))
  end

  test "should destroy top" do
    assert_difference('Top.count', -1) do
      delete :destroy, id: @top.to_param
    end

    assert_redirected_to tops_path
  end
end
