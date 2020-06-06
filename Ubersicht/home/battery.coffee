commands =
  battery: "pmset -g batt | egrep '([0-9]+\%).*' -o --colour=auto | cut -f1 -d';'"
  ischarging: "sh ./home/scripts/ischarging.sh"

command: "echo " +
         "$(#{ commands.battery }):::" +
         "$(#{ commands.ischarging }):::"

refreshFrequency: "5 s"

render: (output) ->
  """
  <div class="themeable block block-1x1 battery">
    <p></p>
  </div>
  """

update: (output, domEl) ->
  output = output.split( /:::/g )
  @handleBattery(output[0], output[1], domEl)

handleBattery: (percent, charging, domEl) ->
  if charging == "true"
    $(".battery p").text("#{ percent } ✔")
  else
    $(".battery p").text("#{ percent } ✖")
