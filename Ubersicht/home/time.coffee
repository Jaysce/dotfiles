command: "date +\"%a %d %b %I:%M\""

refreshFrequency: "5 s"

render: (output) ->
  """
  <div class="themeable block block-1x2 time">
    <p></p>
  </div>
  """

update: (output, domEl) ->
  @handleTime(output, domEl)

handleTime: (time, domEl) ->
  $(".time p").text("#{ time }")
