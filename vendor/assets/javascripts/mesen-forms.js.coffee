//= require bootstrap
//= require bootstrap-datepicker
//= require nested-form
//= require image-processing

$(document).ready(
  ($)->
    window.bind_datepicker('.datepicker')
    window.bind_processing()

  # bind the loader message
  $('.form-actions').find('.btn').on('click', () ->
    $(this).button('loading')
  )
)

window.bind_datepicker = (selector, date_format) ->
  if (date_format == undefined)
    date_format = 'yy-mm-dd'
  $('.datepicker').datepicker({weekStart: 1, dateFormat: date_format})