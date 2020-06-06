command: "osascript -e 'tell application \"Spotify\" to if player state is playing then artist of current track & \" - \" & name of current track'"

refreshFrequency: "5 s"

render: (output) ->
  """
  <div class="themeable block-1x4 music">
    <p class="m"></p>
  </div>
  """

update: (output, domEl) ->
  @handleMusic(output, domEl)

handleMusic: (song, domEl) ->
  if(!song || song == "")
    # $(".music").css("display", "none")
    $(".m").empty()
    $(".m").append("<b>〜(￣▽￣〜) 〜〜〜〜〜〜〜〜 (〜￣▽￣)〜</b>")
  else
    $(".music").css("display", "flex")
    $(".music p").text("#{ song }")
