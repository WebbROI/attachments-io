require 'test_helper'

class StreamingControllerTest < ActionController::TestCase
  test "should get events" do
    get :events
    assert_response :success
  end

end
