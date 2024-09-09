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

  // disable:
  function disable_tag(tag_id) {
    let tag = $("#" + tag_id);
    tag.prop("disabled", true);
  }

  // enable tag:
  function enable_tag(tag_id) {
    let tag = $("#" + tag_id);
    tag.prop("disabled", false);
  }

  // auth form:
  function show_auth_form_loader() {
    let loader = $("." + "auth_form_loader");
    loader.show();
  }

  function hide_auth_form_loader() {
    let loader = $("." + "auth_form_loader");
    loader.hide();
  }

  function disable_auth_btn(btn_id) {
    disable_tag(btn_id);
    show_auth_form_loader();
  }

  function enable_auth_btn(btn_id) {
    enable_tag(btn_id);
    hide_auth_form_loader();
  }

  Shiny.addCustomMessageHandler("enable_auth_btn", (message) => {
    enable_auth_btn(message["id"]);
  });
});
