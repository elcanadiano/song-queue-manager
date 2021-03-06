//= require html.sortable.min

$(function() {
  $('#song_request_band_id').change(function() {
    $('#hidden-admin').toggle($('#song_request_band_id').val() == '0');
  });

  sortable('#song-requests', {
    items: ':not(.disabled)'
  });

  sortable("#song-requests")[0].addEventListener('sortupdate', function(e) {
    var ob = {
      request_id: e.detail.item.dataset.requestId,
      new_index: e.detail.index
    }

    $.ajax({
      method:   "PATCH",
      dataType: "json",
      url:      "/song_requests/reorder",
      data:     ob,
      success:  function(data, status, jqXHR) {
        $('#ajax-alert > span').text(data.message);
        $('#ajax-alert').removeClass(function(index, className) {
          return (className.match (/(^|\s)alert-\S+/g) || []).join(' ');
        }).addClass("alert-" + data.status).slideDown(200);
      },
      error:    function(jqXHR, status, errorThrown) {
        // TODO: Undo the reordering if error.
        $('#ajax-alert > span').text(jqXHR.responseJSON.message);
        $('#ajax-alert').removeClass(function(index, className) {
          return (className.match (/(^|\s)alert-\S+/g) || []).join(' ');
        }).addClass("alert-" + jqXHR.responseJSON.status).slideDown(200);
      }
    });
  });
});
