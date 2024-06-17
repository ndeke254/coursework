$(document).ready(function () {
  $("#modal").modal({
    backdrop: "static", // Prevent closing when clicking outside
    keyboard: false, // Prevent closing with the ESC key
    show: false,
  });

  if (!screenfull.isEnabled) {
    return false;
  }

  $("#full_screen_btn").click(function () {
    if (screenfull.isFullscreen) {
      screenfull.exit();
      $("#full_screen_btn i").removeClass("fa-compress").addClass("fa-expand");
    } else {
      screenfull.request(this);
      $("#full_screen_btn i").removeClass("fa-expand").addClass("fa-compress");
    }
  });
});
