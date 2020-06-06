command: "osascript -e 'output volume of (get volume settings)'"

refreshFrequency: "5 s"

render: (output) ->
  """
  <div class="themeable block block-1x1 volume">
    <p>volume</p>
  </div>
  """

update: (output, domEl) ->
  @handleVolume(output, domEl)

handleVolume: (vol, domEl) ->
  if(vol >= 31)
    $(".volume p").text("♭")
  else
    $(".volume p").text("♯")
