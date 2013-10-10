require 'test_helper'

class SyncControllerTest < ActionController::TestCase
  test "should get start" do
    get :start
    assert_response :success
  end

  test "should get details" do
    get :details
    assert_response :success
  end

end
