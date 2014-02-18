NS = namespace('shoogl.scene.generators.standard')
class NS.Vector3DomOutputGenerator
  constructor: () ->
    @in =
      value_vec3: new THREE.Vector3(0, 0, 0)

    container = $('<span class="vec3"></span>')
    @_x_span = @_make_component_dom('x', 'r', 'number')
    @_y_span = @_make_component_dom('y', 'g', 'number')
    @_z_span = @_make_component_dom('z', 'b', 'number')
    $(container).append @_x_span, @_y_span, @_z_span

    @out =
      output_dom: container

    @name = "Float DOM element"
    @description = "DOM element which displays a float value"

  update: () ->
    return unless @in?.value_vec3?

    @_format_value @in.value_vec3.x, @_x_span
    @_format_value @in.value_vec3.y, @_y_span
    @_format_value @in.value_vec3.z, @_z_span

  _format_value: (value, element) ->
    if $(element).hasClass 'mouseover'
      value_string = "#{value}"
    else
      value_string = value.toFixed(4)

    $(element).text value_string

  _make_component_dom: (css_classes...) ->
    dom = $('<span></span>')
    $(dom).addClass css_classes.join(' ')
    $(dom).on "mouseover", (e) => $(dom).addClass('mouseover')
    $(dom).on "mouseout", (e) => $(dom).removeClass('mouseover')
    return dom
