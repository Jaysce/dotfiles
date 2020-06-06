refreshFrequency: false

render: (output) ->
  """
  <div class="themeable block focus block-1x1 power">
    <p></p>
  </div>
  """

# --
# -- Interactive: sleep computer on click
# --

afterRender: (domEl) ->
  $(domEl).on 'click', '.power', =>
    @run "pmset sleepnow"
