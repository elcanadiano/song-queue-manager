require 'test_helper'

class UsersBandsTest < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:alexander)
    @non_admin = users(:erin)
    @band      = bands(:h4h)
  end

  test "bands admin has edit links" do
    log_in_as(@admin)
    get bands_user_path(@admin)
    assert_template 'users/bands'
    assert_select 'a', text: 'Edit', count: 1
  end

  test "bands non-admin has no edit links" do
    log_in_as(@non_admin)
    get bands_user_path(@non_admin)
    assert_select 'a', text: 'Edit', count: 0
  end
end
