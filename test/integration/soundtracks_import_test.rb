require 'test_helper'

class SoundtracksImportTest < ActionDispatch::IntegrationTest

  def setup
    @admin      = users(:alexander)
    @non_admin  = users(:donnie)
    @testimport = soundtracks(:testexistingsoundtrack)
  end

  test "importing a soundtrack" do
    # Visiting the import page redirects out if you're not logged in.
    get import_soundtracks_path
    assert_equal "Please log in.", flash[:danger]
    assert_redirected_to login_url

    # Visiting the import page redirects out if you're not admin.
    log_in_as @non_admin
    get import_soundtracks_path
    assert_equal "This function requires administrator privileges.", flash[:danger]
    assert_redirected_to root_url
    delete logout_path

    # Login as admin.
    log_in_as @admin
    get import_soundtracks_path
    assert_response :success

    assert_difference '@testimport.songs.count', 7 do
      post process_import_soundtracks_path, file: fixture_file_upload('test/fixtures/spreadsheets/elcanadiano2-dlc-11-23-16.csv', 'text/csv'), soundtrack: "Test Existing Soundtrack"
    end

    assert_equal "Songs imported!", flash[:success]
    assert_redirected_to soundtracks_url
  end
end
