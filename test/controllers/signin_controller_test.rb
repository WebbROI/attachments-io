require 'test_helper'

class SigninControllerTest < ActionController::TestCase
  test "should get apps" do
    get :apps
    assert_response :success
  end

  test "should get google" do
    get :google
    assert_response :success
  end

end
