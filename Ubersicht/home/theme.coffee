command: "osascript -e 'tell application \"Finder\" to get posix path of (get desktop picture as alias)'"

refreshFrequency: 500;

render: (output) ->
  """
  <div class="themeable block block-1x2 theme">
    <p></p>
  </div>
  """

update: (output, domEl) ->

  if output.includes "green"
    @handleGreen(domEl)
  else if output.includes "red"
    @handleRed(domEl)
  else if output.includes "pink"
    @handlePink(domEl)

# --
# -- Handle theme switching
# -- This works by overloading CSS variables
# -- based on the name of the desktop image
# --

handleGreen: (domEl) ->
  $(".themeable").removeClass("red")
  $(".themeable").removeClass("pink")
  $(".theamable").addClass("green")
  $(".theme").text("Lily")

handleRed: (domEl) ->
  $(".themeable").removeClass("green")
  $(".themeable").removeClass("pink")
  $(".themeable").addClass("red")
  $(".theme").text("Rose")

handlePink: (domEl) ->
  $(".themeable").removeClass("green")
  $(".themeable").removeClass("red")
  $(".themeable").addClass("pink")
  $(".theme").text("Soft")
