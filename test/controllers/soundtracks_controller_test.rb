require 'test_helper'

class SoundtracksControllerTest < ActionController::TestCase
  def setup
    @admin      = users(:alexander)
    @non_admin  = users(:donnie)
    @soundtrack = soundtracks(:notinrockband)
    @song1      = songs(:devilinherheart)
    @song2      = songs(:rain)
    @song3      = songs(:something)
    @song4      = songs(:dontletmedown)
    @newsong    = songs(:getback)
  end

  test "guests cannot see soundtracks index page" do
    get :index
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot see soundtracks index page" do
    log_in_as(@non_admin)
    get :index
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "guests cannot see new soundtrack page" do
    get :new
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot see new soundtrack page" do
    log_in_as(@non_admin)
    get :new
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "create a new soundtrack" do
    log_in_as(@admin)
    # We are converting the IDs to strings to simulate what actually gets passed
    # to the function as it expects numbers as strings, which we have to convert
    # to integers.
    assert_difference 'Soundtrack.count', 1, 'Creating a request adds one.' do
      post :create, soundtrack: {
        name:  "Songs by The Rutles",
        songs: [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s]
      }
    end
    assert_equal "Soundtrack created successfully!", flash[:success]
    assert_redirected_to soundtracks_url
  end

  test "guests cannot create a new soundtrack" do
    assert_no_difference 'Soundtrack.count', 'Guests will not add to the tally.' do
      post :create, soundtrack: {
        name:  "Songs by The Rutles",
        songs: [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s]
      }
    end
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot create a new soundtrack" do
    log_in_as(@non_admin)
    assert_no_difference 'Soundtrack.count', 'Non-admins will not add to the tally.' do
      post :create, soundtrack: {
        name:  "Songs by The Rutles",
        songs: [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s]
      }
    end
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "cannot create a blank new soundtrack" do
    log_in_as(@admin)
    assert_no_difference 'Soundtrack.count', 'A soundtrack requires a name.' do
      post :create, soundtrack: {
        name:  "",
        songs: [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s]
      }
    end
    assert_template 'new'
  end

  test "can create a new soundtrack without artists" do
    log_in_as(@admin)
    assert_difference 'Soundtrack.count', 1, 'Soundtracks do not actually need artists in the database.' do
      post :create, soundtrack: {
        name:  "Songs by The Rutles",
      }
    end
    assert_equal "Soundtrack created successfully!", flash[:success]
    assert_redirected_to soundtracks_url
  end

  test "guests cannot see edit soundtrack page" do
    get :edit, id: @soundtrack
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot see edit soundtrack page" do
    log_in_as(@non_admin)
    get :edit, id: @soundtrack
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "updating a soundtrack" do
    log_in_as(@admin)
    patch :update, id: @soundtrack, soundtrack: {
      name:  "Songs in Rock Band",
      songs: [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s, @newsong.id.to_s]
    }
    @soundtrack.reload
    assert_equal "Songs in Rock Band", @soundtrack.name
    assert_equal 5, @soundtrack.songs.size
    assert @soundtrack.songs.include?(@newsong)
    assert_equal "Soundtrack Updated!", flash[:success]
    assert_redirected_to soundtracks_url
  end

  test "guests cannot update a soundtrack" do
    patch :update, id: @soundtrack, soundtrack: {
      name:  "Songs in Rock Band",
      songs: [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s, @newsong.id.to_s]
    }
    @soundtrack.reload
    assert_equal "Songs not actually in Rock Band", @soundtrack.name
    assert_equal 8, @soundtrack.songs.size
    assert !@soundtrack.songs.include?(@newsong)
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot update a soundtrack" do
    log_in_as(@non_admin)
    patch :update, id: @soundtrack, soundtrack: {
      name:  "Songs in Rock Band",
      songs: [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s, @newsong.id.to_s]
    }
    @soundtrack.reload
    assert_equal "Songs not actually in Rock Band", @soundtrack.name
    assert_equal 8, @soundtrack.songs.size
    assert !@soundtrack.songs.include?(@newsong)
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "delete a soundtrack" do
    log_in_as(@admin)
    assert_difference 'Soundtrack.count', -1, 'Deleting an soundtrack subtracts one.' do
      delete :destroy, id: @soundtrack
    end
    assert_equal "Soundtrack Deleted.", flash[:success]
    assert_redirected_to soundtracks_url
  end

  test "guests cannot delete a soundtrack" do
    assert_no_difference 'Soundtrack.count', 'Guests cannot delete a soundtrack.' do
      delete :destroy, id: @soundtrack
    end
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot delete a soundtrack" do
    log_in_as(@non_admin)
    assert_no_difference 'Soundtrack.count', 'Non-admins cannot delete a soundtrack.' do
      delete :destroy, id: @soundtrack
    end
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end
end
