var channel = pusher.subscribe('test_channel');

channel.bind('state', function(data) {
  if(data.status == "building") {
    startProgressBar();
  } else {
    $("#progressbar").hide();
  }

  if (data.status == "green") {
    $("#success_audio").get(0).play();
  };

  $("#status").html(data.status);
  $("#build_number").html(data.number);
  $("#velocity").html(data.velocity);
  $(".status").attr("class", "status");
  $(".status").addClass(data.status);
});

var blink = function() {
  for(i=0;i<5;i++) {
    $("#story_info").fadeTo('slow', 0.0).fadeTo('slow', 1.0);
  }
}

channel.bind("story", function(data) {
  var changes = "";
  changes += data.data.message + " ";
  changes += data.data.changes[0].name;
  $("#story_info").html(changes);
  if(changes.indexOf("rejected") !== -1) {
    $("#rejected_audio").get(0).play();
  } else if (changes.indexOf("started") !== -1) {
    $("#notification_audio").get(0).play();
  };
  blink();
});

var startProgressBar = function() {
  $("#progressbar").show();
  $("#building_audio").get(0).play();
  $("#progressbar > div").each(function() {
    $(this)
      .data("origWidth", $(this).width())
      .width(0)
      .animate({
        width: $(this).data("origWidth")
      }, 1200000);
  });
}

$("#progressbar").hide();
