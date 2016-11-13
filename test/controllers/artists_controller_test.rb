require 'test_helper'

class ArtistsControllerTest < ActionController::TestCase
  def setup
    @artist    = artists(:takingbacksunday)
    @admin     = users(:alexander)
    @non_admin = users(:donnie)
  end

  test "guests cannot see artists index page" do
    get :index
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admin can see artists index page" do
    log_in_as(@non_admin)
    get :index
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "guests cannot see new artists page" do
    get :new
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admin can see new artists page" do
    log_in_as(@non_admin)
    get :new
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "create a new artist" do
    log_in_as(@admin)
    assert_difference 'Artist.count', 1, 'Creating a request adds one.' do
      post :create, artist: {
        name: "The Test Artist"
      }
    end
    assert_equal "Artist created successfully!", flash[:success]
    assert_redirected_to artists_url
  end

  test "guests cannot create a new artist" do
    assert_no_difference 'Artist.count', 'Guests will not add to the tally.' do
      post :create, artist: {
        name: "The Test Artist"
      }
    end
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot create a new artist" do
    log_in_as(@non_admin)
    assert_no_difference 'Artist.count', 'Non-admins will not add to the tally.' do
      post :create, artist: {
        name: "The Test Artist"
      }
    end
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "cannot create a blank new artist" do
    log_in_as(@admin)
    assert_no_difference 'Artist.count', 'An artist requires a name.' do
      post :create, artist: {
        name: ""
      }
    end
    assert_template 'new'
  end

  test "guests cannot see edit artist page" do
    get :edit, id: @artist
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admin can see edit artist page" do
    log_in_as(@non_admin)
    get :edit, id: @artist
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "updating an artist" do
    log_in_as(@admin)
    patch :update, id: @artist, artist: {
      name: "Taking Back Monday"
    }
    @artist.reload
    assert "Taking Back Monday", @artist.name
    assert_equal "Artist Updated!", flash[:success]
    assert_redirected_to artists_url
  end

  test "guests cannot update an artist" do
    patch :update, id: @artist, artist: {
      name: "Taking Back Monday"
    }
    @artist.reload
    assert "Taking Back Sunday", @artist.name
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot update an artist" do
    log_in_as(@non_admin)
    patch :update, id: @artist, artist: {
      name: "Taking Back Monday"
    }
    @artist.reload
    assert "Taking Back Sunday", @artist.name
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "delete an artist" do
    log_in_as(@admin)
    assert_difference 'Artist.count', -1, 'Deleting an artist subtracts one.' do
      delete :destroy, id: @artist
    end
    assert_equal "Artist Deleted.", flash[:success]
    assert_redirected_to artists_url
  end

  test "guests cannot delete an artist" do
    assert_no_difference 'Artist.count', 'Guests cannot delete an artist.' do
      delete :destroy, id: @artist
    end
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot delete an artist" do
    log_in_as(@non_admin)
    assert_no_difference 'Artist.count', 'Non-admins cannot delete an artist.' do
      delete :destroy, id: @artist
    end
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end
end
