NS = namespace('shoogl.scene.generators')
class NS.TypeTools
  constructor: () ->

  @type_string: (field_name) ->
    type = null
    if field_name?
      parts = field_name.split "_"
      if parts.length > 0
        type = parts.pop()

    return type

  @types_equal: (field_name_a, field_name_b) ->
    a_type = @type_string(field_name_a)
    b_type = @type_string(field_name_b)
    a_type? and a_type == b_type
