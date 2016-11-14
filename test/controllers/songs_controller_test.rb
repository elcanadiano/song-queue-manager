require 'test_helper'

class SongsControllerTest < ActionController::TestCase
  def setup
    @admin          = users(:alexander)
    @non_admin      = users(:donnie)
    @song           = songs(:stopdragging)
    @song_to_delete = songs(:song_to_delete)
    @artist1        = artists(:stevienicks)
    @artist2        = artists(:tompetty)
  end

  test "guests cannot see songs index page" do
    get :index
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot see songs index page" do
    log_in_as(@non_admin)
    get :index
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "guests cannot see new song page" do
    get :new
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot see new song page" do
    log_in_as(@non_admin)
    get :new
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "create a new song" do
    log_in_as(@admin)
    assert_difference 'Song.count', 1, 'Creating a request adds one.' do
      post :create, song: {
        name:    "The Saints Are Coming",
        artists: "U2;Green Day"
      }
    end
    assert_equal "Song created successfully!", flash[:success]
    assert_redirected_to songs_url
  end

  test "guests cannot create a new song" do
    assert_no_difference 'Song.count', 'Guests will not add to the tally.' do
      post :create, song: {
        name:    "The Saints Are Coming",
        artists: "U2;Green Day"
      }
    end
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot create a new song" do
    log_in_as(@non_admin)
    assert_no_difference 'Song.count', 'Non-admins will not add to the tally.' do
      post :create, song: {
        name:    "The Saints Are Coming",
        artists: "U2;Green Day"
      }
    end
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "cannot create a blank new song" do
    log_in_as(@admin)
    assert_no_difference 'Song.count', 'A song requires a name.' do
      post :create, song: {
        name:    "",
        artists: "U2;Green Day"
      }
    end
    assert_template 'new'
  end

  test "cannot create a new song without artists" do
    log_in_as(@admin)
    assert_no_difference 'Song.count', 'Songs need artists in the database.' do
      post :create, song: {
        name:    "The Saints Are Coming",
      }
    end
    assert_template 'new'
  end

  test "guests cannot see edit song page" do
    get :edit, id: @song
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admin can see edit song page" do
    log_in_as(@non_admin)
    get :edit, id: @song
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "updating a song" do
    log_in_as(@admin)
    patch :update, id: @song, song: {
      name:    "Stop Draggin' My Heart Around",
      artists: "Stevie Nicks;Tom Petty"
    }
    @song.reload
    assert_equal "Stop Draggin' My Heart Around", @song.name
    assert_equal 2, @song.artists.size
    assert @song.artists.include?(@artist1)
    assert @song.artists.include?(@artist2)
    assert_equal "Song Updated!", flash[:success]
    assert_redirected_to songs_url
  end

  test "guests cannot update a song" do
    patch :update, id: @song, song: {
      name:    "Stop Draggin' My Heart Around",
      artists: "Stevie Nicks;Tom Petty"
    }
    @song.reload
    assert_equal "Stop Dragging My Heart Around", @song.name
    assert_equal 1, @song.artists.size
    assert @song.artists.include?(@artist1)
    assert !@song.artists.include?(@artist2)
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot update a song" do
    log_in_as(@non_admin)
    patch :update, id: @song, song: {
      name:    "Stop Draggin' My Heart Around",
      artists: "Stevie Nicks;Tom Petty"
    }
    @song.reload
    assert_equal "Stop Dragging My Heart Around", @song.name
    assert_equal 1, @song.artists.size
    assert @song.artists.include?(@artist1)
    assert !@song.artists.include?(@artist2)
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "delete a song" do
    log_in_as(@admin)

    # Song to Delete has one song request associated with it.
    assert !SongRequest.find_by(song_id: @song_to_delete.id).blank?

    assert_difference 'Song.count', -1, 'Deleting an song subtracts one.' do
      delete :destroy, id: @song_to_delete
    end

    # Because the song was deleted, all associated requests were too.
    assert SongRequest.find_by(song_id: @song_to_delete.id).blank?

    assert_equal "Song Deleted.", flash[:success]
    assert_redirected_to songs_url
  end

  test "guests cannot delete a song" do
    # Song to Delete has one song request associated with it.
    assert !SongRequest.find_by(song_id: @song_to_delete.id).blank?

    assert_no_difference 'Song.count', 'Guests cannot delete a song.' do
      delete :destroy, id: @song_to_delete
    end

    # Because the song was not deleted, the request wasn't either.
    assert !SongRequest.find_by(song_id: @song_to_delete.id).blank?

    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot delete a song" do
    log_in_as(@non_admin)

    # Song to Delete has one song request associated with it.
    assert !SongRequest.find_by(song_id: @song_to_delete.id).blank?

    assert_no_difference 'Song.count', 'Non-admins cannot delete a song.' do
      delete :destroy, id: @song_to_delete
    end

    # Because the song was not deleted, the request wasn't either.
    assert !SongRequest.find_by(song_id: @song_to_delete.id).blank?

    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end
end
