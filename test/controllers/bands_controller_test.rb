require 'test_helper'

class BandsControllerTest < ActionController::TestCase
  def setup
    @non_member                  = users(:lana)
    @member                      = users(:erin)
    @other_member                = users(:andrew)
    @user_admin                  = users(:michael)
    @non_admin                   = users(:archer)
    @band_admin                  = users(:roger)
    @other_band_admin            = users(:anne)
    @invited                     = users(:chris)
    @single_admin                = users(:dankey)
    @band_user_admin             = users(:band_user_admin)
    @band_user_admin_membership  = members(:band_user_admin)
    @single_admin_membership     = members(:dankey)
    @band_admin_membership       = members(:roger)
    @membership                  = members(:erin)
    @other_band_admin_membership = members(:anne)
    @band                        = bands(:h4h)
    @single_admin_band           = bands(:dankey)
    @delete_band                 = bands(:delete)
    @band_user_band              = bands(:band_user_admin)
  end

  # Usually the "Please log in." error would show but this is the preferred
  # error for this function so the logged_in_user method is not called.
  test "guests cannot see index" do
    get :index
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "non-admins cannot see index" do
    log_in_as(@non_admin)
    get :index
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "guests cannot see new band page" do
    get :new
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "logged in users can see new band page" do
    log_in_as(@non_member)
    get :new
    assert flash.empty?
    assert_response :success
  end

  test "guests cannot create a band" do
    band_name = "The Left Ahead"

    assert !Band.exists?(name: band_name)

    assert_no_difference 'Band.count', "There should not be a band created" do
      post :create, band: {
        name: band_name
      }
    end

    assert !Band.exists?(name: band_name)

    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "logged in members can create a band" do
    band_name = "The Left Ahead"
    log_in_as(@non_member)

    assert !Band.exists?(name: band_name)

    assert_difference 'Band.count', 1, "There should be a band created" do
      post :create, band: {
        name: band_name
      }
    end

    assert     Band.exists?(name: band_name)
    new_band = Band.find_by(name: band_name)

    assert_equal "#{band_name} created!", flash[:success]
    assert_redirected_to band_url(new_band)
  end

  test "cannot create a band with existing name case insensitive" do
    band_name = "HarmONIes for HiRE"
    log_in_as(@non_member)

    assert !Band.exists?(name: band_name)

    assert_no_difference 'Band.count', "There already exists a band called Harmonies for Hire." do
      post :create, band: {
        name: band_name
      }
    end

    assert     !Band.exists?(name: band_name)

    assert flash.empty?
    assert_template 'new'
  end

  test "cannot create a band without a name" do
    log_in_as(@non_member)

    assert_no_difference 'Band.count', "There already exists a band called Harmonies for Hire." do
      post :create, band: {
        name: ''
      }
    end

    assert flash.empty?
    assert_template 'new'
  end

  test "guests cannot see band info" do
    get :show, id: @band.id
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-members can see band info" do
    log_in_as(@non_member)
    get :show, id: @band.id
    assert_response :success
  end

  test "members can see band info" do
    log_in_as(@member)
    get :show, id: @band.id
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get :new
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "should see new when logged in" do
    log_in_as(@member)
    get :new
    assert flash.empty?
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @band
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "should redirect edit when not admin" do
    log_in_as(@member)
    get :edit, id: @band
    assert_equal "You are not authorized to manage this band.", flash[:danger]
    assert_redirected_to root_url
  end

  test "should reach edit when band admin" do
    log_in_as(@band_admin)
    get :edit, id: @band
    assert flash.empty?
    assert_response :success
  end

  test "should reach edit when user admin" do
    log_in_as(@user_admin)

    # Michael, the user admin is not supposed to be part of the band.
    assert !Member.exists?(band_id: @band, user_id: @user_admin)

    get :edit, id: @band
    assert flash.empty?
    assert_response :success
  end

  test "should not update if not logged in" do
    patch :update, id: @band, band: { name: "Harmonies for Hire Starship" }
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "should not update if not admin" do
    log_in_as(@member)
    patch :update, id: @band, band: { name: "Harmonies for Hire Starship" }
    assert_equal "You are not authorized to manage this band.", flash[:danger]
    assert_redirected_to root_url
  end

  test "should update if band admin" do
    log_in_as(@band_admin)
    patch :update, id: @band, band: { name: "Harmonies for Hire Starship" }
    assert_equal "Band updated!", flash[:success]
    assert_redirected_to band_url(@band)
  end

  test "should update if user admin" do
    log_in_as(@user_admin)

    # Michael, the user admin is not supposed to be part of the band.
    assert !Member.exists?(band_id: @band, user_id: @user_admin)

    patch :update, id: @band, band: { name: "Harmonies for Hire Starship" }
    assert_equal "Band updated!", flash[:success]
    assert_redirected_to band_url(@band)
  end

  test "guests cannot delete a band" do
    assert SongRequest.exists?(band_id: @delete_band.id)
    assert Member.exists?(band_id: @delete_band.id)

    assert_no_difference "Band.count" do
      delete :destroy, id: @delete_band
    end

    assert SongRequest.exists?(band_id: @delete_band.id)
    assert Member.exists?(band_id: @delete_band.id)

    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot delete a band" do
    log_in_as(@non_admin)
    assert SongRequest.exists?(band_id: @delete_band.id)
    assert Member.exists?(band_id: @delete_band.id)

    assert_no_difference "Band.count" do
      delete :destroy, id: @delete_band
    end

    assert SongRequest.exists?(band_id: @delete_band.id)
    assert Member.exists?(band_id: @delete_band.id)

    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "band admins cannot delete a band" do
    # This assumes that Roger, the band admin, is NOT a user admin. He should
    # not be.
    log_in_as(@band_admin)
    assert SongRequest.exists?(band_id: @delete_band.id)
    assert Member.exists?(band_id: @delete_band.id)

    assert_no_difference "Band.count" do
      delete :destroy, id: @delete_band
    end

    assert SongRequest.exists?(band_id: @delete_band.id)
    assert Member.exists?(band_id: @delete_band.id)

    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "delete a band" do
    log_in_as(@user_admin)

    assert SongRequest.exists?(band_id: @delete_band.id)
    assert Member.exists?(band_id: @delete_band.id)

    assert_difference "Band.count", -1 do
      delete :destroy, id: @delete_band
    end

    assert !SongRequest.exists?(band_id: @delete_band.id)
    assert !Member.exists?(band_id: @delete_band.id)

    assert_equal "Band Deleted.", flash[:success]
    assert_redirected_to bands_url
  end

  test "should redirect invite when not logged in" do
    get :invite, id: @band
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "should redirect invite when not admin" do
    log_in_as(@member)
    get :invite, id: @band
    assert_equal "You are not authorized to manage this band.", flash[:danger]
    assert_redirected_to root_url
  end

  test "should reach invite when band admin" do
    log_in_as(@band_admin)
    get :invite, id: @band
    assert flash.empty?
    assert_response :success
  end

  test "should reach invite when user admin" do
    log_in_as(@user_admin)

    # Michael, the user admin is not supposed to be part of the band.
    assert !Member.exists?(band_id: @band, user_id: @user_admin)

    get :invite, id: @band
    assert flash.empty?
    assert_response :success
  end

  test "send invite" do
    log_in_as(@band_admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @non_member.id, creator_id: @band_admin.id}
    assert_equal "Invite sent!", flash[:success]
    assert_redirected_to band_url(@band)
  end

  test "user admins can send invite" do
    log_in_as(@user_admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @non_member.id, creator_id: @user_admin.id}
    assert_equal "Invite sent!", flash[:success]
    assert_redirected_to band_url(@band)
  end

  test "incorrect creator does not send invite" do
    log_in_as(@band_admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @non_member.id, creator_id: @member.id}
    assert_equal "It has been detected that the parameters were incorrectly modified.", flash[:danger]
    assert_redirected_to invite_band_url
  end

  test "invite not sent if user does not exist" do
    log_in_as(@band_admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: -99999, creator_id: @band_admin.id}
    assert_equal "User not found.", flash[:danger]
    assert_redirected_to invite_band_url
  end

  test "invite not sent if user is already invited" do
    log_in_as(@band_admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @invited.id, creator_id: @band_admin.id}
    assert_equal "An invite has been sent to this user already.", flash[:danger]
    assert_redirected_to invite_band_url
  end

  test "invite not sent to current member" do
    log_in_as(@band_admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @member.id, creator_id: @band_admin.id}
    assert_equal "This user is already a member of the band.", flash[:danger]
    assert_redirected_to invite_band_url
  end

  test "remove member from band" do
    log_in_as(@band_admin)
    assert_difference 'Member.count', -1, 'A member should be removed.' do
      delete :remove_member, id: @band, user_id: @member.id
    end
    assert_equal "The user is no longer part of the band!", flash[:success]
    assert_redirected_to band_url(@band)
  end

  test "user admins can remove member from band" do
    log_in_as(@user_admin)

    # Michael, the user admin is not supposed to be part of the band.
    assert !Member.exists?(band_id: @band, user_id: @user_admin)

    assert_difference 'Member.count', -1, 'A member should be removed.' do
      delete :remove_member, id: @band, user_id: @member.id
    end
    assert_equal "The user is no longer part of the band!", flash[:success]
    assert_redirected_to band_url(@band)
  end

  test "guests cannot remove member from band" do
    assert_no_difference 'Member.count', 'A guest cannot remove a member.' do
      delete :remove_member, id: @band, user_id: @member.id
    end
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admin members cannot remove member from band" do
    log_in_as(@other_member)
    assert_no_difference 'Member.count', 'A non-admin cannot remove a member.' do
      delete :remove_member, id: @band, user_id: @member.id
    end
    assert_equal "You are not authorized to manage this band.", flash[:danger]
    assert_redirected_to root_url
  end

  test "cannot remove non-member from band" do
    log_in_as(@band_admin)
    assert_no_difference 'Member.count', 'Cannot remove a non-member.' do
      delete :remove_member, id: @band, user_id: @non_member.id
    end
    assert_equal "This user not a member of the band.", flash[:danger]
    assert_redirected_to band_url(@band)
  end

  test "cannot remove yourself from a band" do
    log_in_as(@band_admin)
    assert_no_difference 'Member.count', 'Cannot remove yourself.' do
      delete :remove_member, id: @band, user_id: @band_admin.id
    end
    assert_equal "You cannot remove yourself from the band.", flash[:danger]
    assert_redirected_to band_url(@band)
  end

  test "can remove yourself from a band if you are an admin" do
    log_in_as(@band_user_admin)
    assert_difference 'Member.count', -1, 'A member should be removed.' do
      delete :remove_member, id: @band_user_band, user_id: @band_user_admin
    end
    assert_equal "The user is no longer part of the band!", flash[:success]
    assert_redirected_to band_url(@band_user_band)
  end

  test "cannot remove an admin from a band" do
    log_in_as(@band_admin)
    assert_no_difference 'Member.count', 'Cannot remove yourself.' do
      delete :remove_member, id: @band, user_id: @other_band_admin.id
    end
    @other_band_admin_membership.reload
    assert @other_band_admin_membership.is_admin?
    assert_equal "You cannot remove an admin from the band. They must step down first.", flash[:danger]
    assert_redirected_to band_url(@band)
  end

  test "promote member to band admin" do
    log_in_as(@band_admin)
    assert !@membership.is_admin?
    patch :promote_to_admin, id: @band, user_id: @member.id
    @membership.reload
    assert @membership.is_admin?
    assert_equal "The user has been promoted to admin!", flash[:success]
    assert_redirected_to band_url(@band)
  end

  test "user admins can promote member to band admin" do
    log_in_as(@user_admin)

    # Michael, the user admin is not supposed to be part of the band.
    assert !Member.exists?(band_id: @band, user_id: @user_admin)

    assert !@membership.is_admin?
    patch :promote_to_admin, id: @band, user_id: @member.id
    @membership.reload
    assert @membership.is_admin?
    assert_equal "The user has been promoted to admin!", flash[:success]
    assert_redirected_to band_url(@band)
  end

  test "guests cannot promote member to band admin" do
    assert !@membership.is_admin?
    patch :promote_to_admin, id: @band, user_id: @member.id
    @membership.reload
    assert !@membership.is_admin?
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-members cannot promote member to band admin" do
    log_in_as(@other_member)
    assert !@membership.is_admin?
    patch :promote_to_admin, id: @band, user_id: @member.id
    @membership.reload
    assert !@membership.is_admin?
    assert_equal "You are not authorized to manage this band.", flash[:danger]
    assert_redirected_to root_url
  end

  test "promote nonmember to band admin" do
    log_in_as(@band_admin)
    patch :promote_to_admin, id: @band, user_id: @non_member.id
    assert_equal "This user not a member of the band.", flash[:danger]
    assert_redirected_to band_url(@band)
  end

  test "cannot promote an band admin" do
    log_in_as(@band_admin)
    patch :promote_to_admin, id: @band, user_id: @other_band_admin.id
    assert_equal "The user is already an admin.", flash[:danger]
    assert_redirected_to band_url(@band)
  end

  test "step down as band admin" do
    log_in_as(@band_admin)
    assert @band_admin_membership.is_admin?
    patch :step_down, id: @band, user_id: @band_admin
    assert_equal "You have stepped down as an admin.", flash[:success]
    @band_admin_membership.reload
    assert !@band_admin_membership.is_admin?
    assert_redirected_to band_url(@band)
  end

  test "user admins can force a step down" do
    log_in_as(@user_admin)

    # Michael, the user admin is not supposed to be part of the band.
    assert !Member.exists?(band_id: @band, user_id: @user_admin)

    assert @band_admin_membership.is_admin?
    patch :step_down, id: @band, user_id: @band_admin
    assert_equal "You have stepped down as an admin.", flash[:success]
    @band_admin_membership.reload
    assert !@band_admin_membership.is_admin?
    assert_redirected_to band_url(@band)
  end

  test "non-admins cannot step down" do
    log_in_as(@member)
    patch :step_down, id: @band, user_id: @member
    assert_equal "You are not authorized to manage this band.", flash[:danger]
    assert_redirected_to root_url
  end

  test "cannot step down if there does not exist another admin" do
    log_in_as(@single_admin)
    assert @single_admin_membership.is_admin?
    patch :step_down, id: @single_admin_band, user_id: @single_admin
    assert_equal "There needs to be another admin before you step down.", flash[:danger]
    @single_admin_membership.reload
    assert @single_admin_membership.is_admin?
    assert_redirected_to band_url(@single_admin_band)
  end

  test "user admins can force a step down even if there does not exist another admin" do
    log_in_as(@user_admin)
    assert @single_admin_membership.is_admin?
    patch :step_down, id: @single_admin_band, user_id: @single_admin
    assert_equal "You have stepped down as an admin.", flash[:success]
    @single_admin_membership.reload
    assert !@single_admin_membership.is_admin?
    assert_redirected_to band_url(@single_admin_band)
  end
end
