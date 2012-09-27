//= require bootstrap.min
//= require bootstrap-datepicker
//= require nested-form

$(document).ready(
  ($)->
    window.bind_datepicker('.datepicker')
)

window.bind_datepicker = (selector, date_format) ->
  $('.datepicker').datepicker({weekStart: 1})