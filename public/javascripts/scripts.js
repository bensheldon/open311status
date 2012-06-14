$(document).ready(function() {
  $("[rel=tooltip]").tooltip();

  // Services Modal
  $("#endpoints").on("click", "a[data-toggle=modal]", function() {
    var target = $(this).attr('data-target') || $(this).attr('href');
    if (target === "#servicesModal") {
   	  var city = $(this).attr('data-city');
      
      $.ajax({
        url: "/services/" + city,
      }).done(function ( content ) {
        $("#servicesAjax").html(content);
      });
    }
  });
  // replace with the "loading" prompt after close
  $('#servicesModal').on('hidden', function () {
    $("#servicesAjax").html('<div class="modal-body">loading . . .</div>');
  });
})
