//= require bootstrap
//= require bootstrap-datepicker
//= require nested-form
//= require image-processing

$(document).ready(
  ($)->
    window.bind_datepicker('.datepicker')
    window.bind_processing()

  # bind the loader message
  $('.btn').on('click', () ->
    $(this).button('loading')
  )
)

window.bind_datepicker = (selector, date_format) ->
  $('.datepicker').datepicker({weekStart: 1})