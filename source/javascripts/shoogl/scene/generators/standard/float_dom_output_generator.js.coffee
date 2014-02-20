NS = namespace('shoogl.scene.generators.standard')
class NS.FloatDomOutputGenerator
  constructor: () ->
    @in =
      value_f: 0.0

    dom = $('<span class="number"></span>')
    $(dom).on "mouseover", (e) => $(dom).addClass('mouseover')
    $(dom).on "mouseout", (e) => $(dom).removeClass('mouseover')

    @out =
      output_dom: dom

    @name = "Float DOM element"
    @description = "DOM element which displays a float value"

  update: () ->
    return unless @in?.value_f?

    if $(@out.output_dom).hasClass 'mouseover'
      value_string = "#{@in.value_f}"
    else
      value_string = @in.value_f.toFixed(4)

    $(@out.output_dom).text value_string
