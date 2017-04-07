$(function() {
  $('#song_request_band_id').change(function() {
    alert($('#song_request_band_id').val());
    $('#hidden-admin').toggle($('#song_request_band_id').val() == '0');
  });
});
