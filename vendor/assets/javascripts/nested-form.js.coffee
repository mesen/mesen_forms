class NestedForm
  constructor: (@selector) ->
    # the jquery element should be the field_wrapper
    this.j_el = $(selector)
    if (this.j_el).length > 0
      this.bind_add_button()
      this.bind_directional_buttons()
      this.set_directional_button_ability()
      this.bind_remove_buttons()
      
  set_directional_button_ability: () ->
    num_fields = this.j_el.find('.fields:visible').length
    if num_fields < 2
      this.j_el.find('.directional-btn').addClass('disabled')
    else
      this.j_el.find('.directional-btn').removeClass('disabled')
      this.j_el.find('.fields:visible:first').find('.move-field-up').addClass('disabled')
      this.j_el.find('.fields:visible:last').find('.move-field-down').addClass('disabled')

  bind_directional_buttons: () ->
    this.bind_up()
    this.bind_down()

  bind_up: () ->
    nested_form = this
    this.j_el.find('.move-field-up').bind('click', (event) ->
      if $(this).hasClass('disabled')
        return false
      else
        fields = $(this).parent().parent().parent().parent()
        fields_wrapper = fields.parent()
        previous_fields = fields.prev(':visible')
        if previous_fields.length == 0
          previous_fields = fields.prevUntil(':visible').last().prev()
        fields.detach()
        fields.insertBefore(previous_fields)
        nested_form.set_order_num(fields_wrapper)
        nested_form.set_directional_button_ability(fields_wrapper)
      event.preventDefault()
    )

  bind_down: () ->
    nested_form = this
    this.j_el.find('.move-field-down').bind('click', (event) ->
      if $(this).hasClass('disabled')
        return false
      else
        fields = $(this).parent().parent().parent().parent()
        fields_wrapper = fields.parent()
        next_fields = fields.next(':visible')
        if next_fields.length == 0
          next_fields = fields.nextUntil(':visible').last().next()
        fields.detach()
        fields.insertAfter(next_fields)
        nested_form.set_order_num(fields_wrapper)
        nested_form.set_directional_button_ability(fields_wrapper)
      event.preventDefault()
    )

  set_order_num: () ->
    this.j_el.find('.fields:visible').each((index) ->
      $(this).find('.order_num').val(index)
    )

  bind_remove_buttons: () ->
    nested_form = this
    this.j_el.find('.remove_fields').bind('click', (event) ->
      $(this).parent().find('.destroy').val('1')
      $(this).parent().parent().parent().parent().hide()
      fields_wrapper = $(this).parent().parent().parent().parent().parent()
      num_fields = fields_wrapper.find('.fields:visible').length
      nested_form.set_directional_button_ability(fields_wrapper)
      nested_form.set_order_num(fields_wrapper)
      if num_fields < 1
        fields_wrapper.find('.empty-list').css({visibility: 'visible', display: 'block'}).show()
      event.preventDefault()
    )

  bind_add_button: () ->
    nested_form = this
    this.j_el.parent().find('.add_fields').bind('click', (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'), 'g')
      $(this).parent().find('.fields-wrapper').append($(this).data('fields').replace(regexp, time))
      $(this).parent().find('.fields-wrapper').find('.empty-list').hide()
      fields_wrapper = $(this).parent().find('.fields-wrapper')
      nested_form.set_directional_button_ability(fields_wrapper)
      nested_form.bind_directional_buttons()
      nested_form.set_order_num(fields_wrapper)
      nested_form.bind_remove_buttons()
      window.bind_datepicker('.datepicker')
      event.preventDefault()
    )

$(document).ready(
  nested_form = new NestedForm('.fields-wrapper')
)