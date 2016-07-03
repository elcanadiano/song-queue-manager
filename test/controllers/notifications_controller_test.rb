require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  def setup
    @noninvitee   = users(:malory)
    @invitee      = users(:chris)
    @notification = notifications(:chris_h4h)
    @expired      = notifications(:chris_dankey_expired)
    @band         = bands(:h4h)
  end

  test "guests cannot access notifications page" do
    get :index
    assert_redirected_to login_url
  end

  test "members can access notifications page" do
    log_in_as @invitee
    get :index
    assert_response :success
  end

  test "guests cannot accept notificiation" do
    patch :accept, id: @notification
    assert_redirected_to login_url
  end

  test "guests cannot decline notificiation" do
    patch :decline, id: @notification
    assert_redirected_to login_url
  end

  test "cannot accept other person's notificiation" do
    log_in_as(@noninvitee)

    assert_no_difference 'Member.count', "Accepting someone else's invite does not add an extra member." do
      patch :accept, id: @notification
    end

    assert_equal "The notification is invalid.", flash[:danger]

    assert_redirected_to root_url
  end

  test "cannot decline other person's notificiation" do
    log_in_as(@noninvitee)

    assert_no_difference 'Member.count', "Declining someone else's invite does not add an extra member." do
      patch :decline, id: @notification
    end

    assert_equal "The notification is invalid.", flash[:danger]

    assert_redirected_to root_url
  end

  test "invitee declines notification" do
    log_in_as(@invitee)

    assert_no_difference 'Member.count', 'Declining an invite does not add an extra member.' do
      patch :decline, id: @notification
    end

    assert_equal "You have declined to join #{@band.name}!", flash[:success]


    assert_redirected_to notifications_url
  end

  test "invitee accepts notification" do
    log_in_as @invitee

    assert_difference 'Member.count', 1, 'Accepting an invite adds an extra member.' do
      patch :accept, id: @notification
    end

    assert_equal "Congratulations! You have joined #{@band.name}!", flash[:success]

    assert_redirected_to band_url(@band.id)
  end

  test "invitee cannot decline expired notification" do
    log_in_as(@invitee)

    assert_no_difference 'Member.count', 'Declining an expired invite does not add an extra member.' do
      patch :decline, id: @expired
    end

    assert_equal "You cannot accept or decline an expired notification.", flash[:danger]


    assert_redirected_to notifications_url
  end

  test "invitee cannot accept expired notification" do
    log_in_as(@invitee)

    assert_no_difference 'Member.count', 'Accepting an expired invite does not add an extra member.' do
      patch :accept, id: @expired
    end

    assert_equal "You cannot accept or decline an expired notification.", flash[:danger]

    assert_redirected_to notifications_url
  end
end
