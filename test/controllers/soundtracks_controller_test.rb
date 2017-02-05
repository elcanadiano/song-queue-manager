require 'test_helper'

class SoundtracksControllerTest < ActionController::TestCase
  def setup
    @admin      = users(:alexander)
    @non_admin  = users(:donnie)
    @soundtrack = soundtracks(:notinrockband)
    @testimport = soundtracks(:testexistingsoundtrack)
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
        description: "This is a description",
        songs: [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s]
      }
    end
    assert_equal "Soundtrack created successfully!", flash[:success]
    assert_redirected_to soundtracks_url
  end

  test "guests cannot create a new soundtrack" do
    assert_no_difference 'Soundtrack.count', 'Guests will not add to the tally.' do
      post :create, soundtrack: {
        name:        "Songs by The Rutles",
        description: "This is a description",
        songs:       [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s]
      }
    end
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot create a new soundtrack" do
    log_in_as(@non_admin)
    assert_no_difference 'Soundtrack.count', 'Non-admins will not add to the tally.' do
      post :create, soundtrack: {
        name:        "Songs by The Rutles",
        description: "This is a description",
        songs:       [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s]
      }
    end
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "cannot create a blank new soundtrack" do
    log_in_as(@admin)
    assert_no_difference 'Soundtrack.count', 'A soundtrack requires a name.' do
      post :create, soundtrack: {
        name:        "",
        description: "This is a description",
        songs:       [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s]
      }
    end
    assert_template 'new'
  end

  test "can create a new soundtrack without artists" do
    log_in_as(@admin)
    assert_difference 'Soundtrack.count', 1, 'Soundtracks do not actually need artists in the database.' do
      post :create, soundtrack: {
        name:        "Songs by The Rutles",
        description: "This is a description",
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
      name:        "Songs in Rock Band",
      description: "This is a description",
      songs:       [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s, @newsong.id.to_s]
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
      name:        "Songs in Rock Band",
      description: "This is a description",
      songs:       [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s, @newsong.id.to_s]
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
      name:        "Songs in Rock Band",
      description: "This is a description",
      songs:       [@song1.id.to_s, @song2.id.to_s, @song3.id.to_s, @song4.id.to_s, @newsong.id.to_s]
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

  test "guests cannot visit import soundtrack" do
    get :import
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot visit import soundtrack" do
    log_in_as(@non_admin)
    get :import
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  test "admins can visit import soundtrack" do
    log_in_as(@admin)
    get :import
    assert flash.empty?
    assert_response :success
  end

  test "guests cannot import a soundtrack" do
    assert_no_difference ['Soundtrack.count', 'Song.count'], "No soundtracks or songs should be added" do
      post :process_import, file: fixture_file_upload('/spreadsheets/elcanadiano2-dlc-11-23-16.csv', 'text/csv'), soundtrack: "new soundtrack"
    end

    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url
  end

  test "non-admins cannot import a soundtrack" do
    log_in_as(@non_admin)

    assert_no_difference ['Soundtrack.count', 'Song.count'], "No soundtracks or songs should be added" do
      post :process_import, file: fixture_file_upload('/spreadsheets/elcanadiano2-dlc-11-23-16.csv', 'text/csv'), soundtrack: "new soundtrack"
    end

    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
  end

  # Testing an import. There are nine songs in the CSV, of which six songs are
  # new (three are existing already). Given the soundtrack name is not found,
  # a new soundtrack should be created with the nine songs, but only six new
  # songs should be added.
  test "admins can import to a new soundtrack" do
    log_in_as(@admin)

    assert_equal 3,  Soundtrack.count
    assert_equal 47, Song.count
    assert           Soundtrack.where(name: "new soundtrack").empty?

    post :process_import, file: fixture_file_upload('/spreadsheets/elcanadiano2-dlc-11-23-16.csv', 'text/csv'), soundtrack: "new soundtrack"

    assert           !Soundtrack.where(name: "new soundtrack").empty?
    new_soundtrack = Soundtrack.find_by(name: "new soundtrack")

    assert_equal 9,  new_soundtrack.songs.count
    assert_equal 4,  Soundtrack.count
    assert_equal 53, Song.count

    assert_equal "Songs imported!", flash[:success]
    assert_redirected_to soundtracks_url
  end

  # Testing an import to an existing soundtrack. Of the nine songs in the
  # spreadsheet, two exist in the existing soundtrack already so the song count
  # should then become 11.
  test "admins can import to an existing soundtrack" do
    log_in_as(@admin)

    assert_equal 3,  Soundtrack.count
    assert_equal 47, Song.count
    assert_equal 4,  @testimport.songs.count

    post :process_import, file: fixture_file_upload('/spreadsheets/elcanadiano2-dlc-11-23-16.csv', 'text/csv'), soundtrack: "Test Existing Soundtrack"

    @testimport.reload

    assert_equal 11, @testimport.songs.count

    assert_equal "Songs imported!", flash[:success]
    assert_redirected_to soundtracks_url
  end
end
