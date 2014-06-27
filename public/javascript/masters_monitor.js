var master_channel = pusher.subscribe('masters_channel');

var whodunit = pusher.subscribe("who_channel");

master_channel.bind('state', function(data) {
  if (data.status == "green") {
    $("#success_audio").get(0).play();
  };

  if(data.status === null) {
    data.status = 'building';
  }

  data.branch = data.branch.replace(new RegExp("_", "g"), "-");
  data.branch =  data.branch.replace(new RegExp("-notonthehighstreet", "g"), "");

  var pervious = $(".masters_builds").find("." + data.branch);

  if(pervious.length !== 0) {
    pervious.removeClass();
    pervious.addClass(data.status);
    pervious.addClass(data.branch + "");
  } else {
    $(".masters_builds").append('<div class="' + data.branch + ' ' + data.status + '">' + data.branch + "</div>");
  }
});

whodunit.bind("state", function(data) {
  console.log(data);
  $(".status").css("background-image", "url('/images/andrew.jpg')");
});
