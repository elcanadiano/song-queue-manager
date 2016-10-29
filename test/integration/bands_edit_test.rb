require 'test_helper'

class BandsEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:alexander)
    @band = bands(:h4h)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_band_path(@band)
    assert_template 'bands/edit'
    patch band_path(@band), band: { name:  ""}
    assert_template 'bands/edit'
  end

  test "successful edit with friendly forwarding" do
    get edit_band_path(@band)
    log_in_as(@user)
    assert_redirected_to edit_band_path(@band)
    name  = "The Left Behind"
    patch band_path(@band), band: { name:  name }
    assert_equal "Band updated!", flash[:success]
    assert_redirected_to bands_user_path(@user)
    @band.reload
    assert_equal name,  @band.name
  end
end
