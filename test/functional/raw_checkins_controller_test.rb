require 'test_helper'

class RawCheckinsControllerTest < ActionController::TestCase
  setup do
    @raw_checkin = raw_checkins(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:raw_checkins)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create raw_checkin" do
    assert_difference('RawCheckin.count') do
      post :create, raw_checkin: @raw_checkin.attributes
    end

    assert_redirected_to raw_checkin_path(assigns(:raw_checkin))
  end

  test "should show raw_checkin" do
    get :show, id: @raw_checkin.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @raw_checkin.to_param
    assert_response :success
  end

  test "should update raw_checkin" do
    put :update, id: @raw_checkin.to_param, raw_checkin: @raw_checkin.attributes
    assert_redirected_to raw_checkin_path(assigns(:raw_checkin))
  end

  test "should destroy raw_checkin" do
    assert_difference('RawCheckin.count', -1) do
      delete :destroy, id: @raw_checkin.to_param
    end

    assert_redirected_to raw_checkins_path
  end
end
