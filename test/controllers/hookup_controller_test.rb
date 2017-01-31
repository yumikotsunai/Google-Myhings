require 'test_helper'

class HookupControllerTest < ActionController::TestCase
  test "should get createchannel" do
    get :createchannel
    assert_response :success
  end

end
