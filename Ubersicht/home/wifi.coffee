command: "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | sed -e \"s/^ *SSID: //p\" -e d"

refreshFrequency: "5 s"

render: (output) ->
  """
  <div class="themeable block block-1x1 wifi">
    <p>wifi</p>
  </div>
  """

update: (output, domEl) ->
  @handleWifi(output, domEl)

handleWifi: (wifi, domEl) ->
  if wifi
    $(".wifi p").text("⋰")
  else
    $(".wifi p").text("⊗")
