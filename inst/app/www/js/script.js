$(document).ready(function () {
  $("#modal").modal({
    backdrop: "static", // Prevent closing when clicking outside
    keyboard: false, // Prevent closing with the ESC key
    show: false,
  });

  // clicking the document takes it to full screen mode
  $(document).on("dblclick", "#modal-content", function () {
    if (!document.fullscreenElement) {
      document.getElementById("modal").requestFullscreen();
    } else {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      }
    }
  });

  // observe the full screen button
  $(document).on("click", "#full_screen_btn", function () {
    if (!document.fullscreenElement) {
      document.getElementById("modal").requestFullscreen();
      $("#full_screen_btn i").removeClass("fa-expand").addClass("fa-compress");
    } else {
      if (document.exitFullscreen) {
        document.exitFullscreen();
        $("#full_screen_btn i")
          .removeClass("fa-compress")
          .addClass("fa-expand");
      }
    }
  });

  $(document).on('shiny:connected', function () {
    function update_network_status() {
      Shiny.setInputValue('network_status', navigator.onLine ? 'online' : 'offline');
    }

    // Add event listeners for online and offline status changes
    window.addEventListener('online', update_network_status);
    window.addEventListener('offline', update_network_status);
  });


  $(document).ready(function () {
    hide_auth_form_loader();
  });

  // show/hide password inputs:
  function toggle_password(password_input_id) {
    let tag = $("#" + password_input_id);
    let type = tag.attr("type");
    tag.attr("type", type === "password" ? "text" : "password");
  }
  
});
