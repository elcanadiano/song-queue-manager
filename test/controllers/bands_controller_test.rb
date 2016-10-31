require 'test_helper'

class BandsControllerTest < ActionController::TestCase
  def setup
    @non_member              = users(:lana)
    @member                  = users(:erin)
    @other_member            = users(:andrew)
    @admin                   = users(:alexander)
    @other_admin             = users(:anne)
    @invited                 = users(:chris)
    @single_admin            = users(:dankey)
    @single_admin_membership = members(:dankey)
    @admin_membership        = members(:alexander)
    @membership              = members(:erin)
    @other_membership        = members(:andrew)
    @other_admin_membership  = members(:anne)
    @band                    = bands(:h4h)
    @single_admin_band       = bands(:dankey)
  end

  test "guests cannot see band info" do
    get :show, id: @band.id
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

  test "should update if admin" do
    log_in_as(@admin)
    patch :update, id: @band, band: { name: "Harmonies for Hire Starship" }
    assert_equal "Band updated!", flash[:success]
    assert_redirected_to bands_user_url(@admin)
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

  test "send invite" do
    log_in_as(@admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @non_member.id, creator_id: @admin.id}
    assert_equal "Invite sent!", flash[:success]
    assert_redirected_to band_url(@band)
  end

  test "incorrect creator does not send invite" do
    log_in_as(@admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @non_member.id, creator_id: @member.id}
    assert_equal "It has been detected that the parameters were incorrectly modified.", flash[:danger]
    assert_redirected_to invite_band_url
  end

  test "invite not sent if user does not exist" do
    log_in_as(@admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: -99999, creator_id: @admin.id}
    assert_equal "User not found.", flash[:danger]
    assert_redirected_to invite_band_url
  end

  test "invite not sent if user is already invited" do
    log_in_as(@admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @invited.id, creator_id: @admin.id}
    assert_equal "An invite has been sent to this user already.", flash[:danger]
    assert_redirected_to invite_band_url
  end

  test "invite not sent to current member" do
    log_in_as(@admin)
    post :create_invite, id: @band, notification: {band_id: @band.id, user_id: @member.id, creator_id: @admin.id}
    assert_equal "This user is already a member of the band.", flash[:danger]
    assert_redirected_to invite_band_url
  end

  test "remove member from band" do
    log_in_as(@admin)
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
    log_in_as(@admin)
    assert_no_difference 'Member.count', 'Cannot remove a non-member.' do
      delete :remove_member, id: @band, user_id: @non_member.id
    end
    assert_equal "This user not a member of the band.", flash[:danger]
    assert_redirected_to band_url(@band)
  end

  test "cannot remove yourself from a band" do
    log_in_as(@admin)
    assert_no_difference 'Member.count', 'Cannot remove yourself.' do
      delete :remove_member, id: @band, user_id: @admin.id
    end
    assert_equal "You cannot remove yourself from the band.", flash[:danger]
    assert_redirected_to band_url(@band)
  end

  test "cannot remove an admin from a band" do
    log_in_as(@admin)
    assert_no_difference 'Member.count', 'Cannot remove yourself.' do
      delete :remove_member, id: @band, user_id: @other_admin.id
    end
    @other_admin_membership.reload
    assert @other_admin_membership.is_admin?
    assert_equal "You cannot remove an admin from the band. They must step down first.", flash[:danger]
    assert_redirected_to band_url(@band)
  end

  test "promote member to admin" do
    log_in_as(@admin)
    assert !@membership.is_admin?
    patch :promote_to_admin, id: @band, user_id: @member.id
    @membership.reload
    assert @membership.is_admin?
    assert_equal "The user has been promoted to admin!", flash[:success]
    assert_redirected_to band_url(@band)
  end

  test "guests cannot promote member to admin" do
    assert !@membership.is_admin?
    patch :promote_to_admin, id: @band, user_id: @member.id
    @membership.reload
    assert !@membership.is_admin?
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-members cannot promote member to admin" do
    log_in_as(@other_member)
    assert !@membership.is_admin?
    patch :promote_to_admin, id: @band, user_id: @member.id
    @membership.reload
    assert !@membership.is_admin?
    assert_equal "You are not authorized to manage this band.", flash[:danger]
    assert_redirected_to root_url
  end

  test "promote nonmember to admin" do
    log_in_as(@admin)
    patch :promote_to_admin, id: @band, user_id: @non_member.id
    assert_equal "This user not a member of the band.", flash[:danger]
    assert_redirected_to band_url(@band)
  end

  test "cannot promote an admin" do
    log_in_as(@admin)
    patch :promote_to_admin, id: @band, user_id: @other_admin.id
    assert_equal "The user is already an admin.", flash[:danger]
    assert_redirected_to band_url(@band)
  end

  test "step down as admin" do
    log_in_as(@admin)
    assert @admin_membership.is_admin?
    patch :step_down, id: @band
    assert_equal "You have stepped down as an admin.", flash[:success]
    @admin_membership.reload
    assert !@admin_membership.is_admin?
    assert_redirected_to band_url(@band)
  end

  test "non-admins cannot step down" do
    log_in_as(@member)
    patch :step_down, id: @band
    assert_equal "You are not authorized to manage this band.", flash[:danger]
    assert_redirected_to root_url
  end

  test "cannot step down if there does not exist another admin" do
    log_in_as(@single_admin)
    assert @single_admin_membership.is_admin?
    patch :step_down, id: @single_admin_band
    assert_equal "There needs to be another admin before you step down.", flash[:danger]
    @single_admin_membership.reload
    assert @single_admin_membership.is_admin?
    assert_redirected_to band_url(@single_admin_band)
  end
end
