require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get signed_in_user" do
    get :signed_in_user
    assert_response :success
  end
end
