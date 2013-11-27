require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get sync" do
    get :sync
    assert_response :success
  end

end
