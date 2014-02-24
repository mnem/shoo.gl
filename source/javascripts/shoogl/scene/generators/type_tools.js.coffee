NS = namespace('shoogl.scene.generators')
class NS.TypeTools
  constructor: () ->

  @type_string: (field_name) ->
    type = ''
    if field_name?
      parts = field_name.split "_"
      if parts.length > 0
        type = parts.pop()

    return type

  @is_array = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'


  @types_equal: (field_name_a, field_name_b) ->
    a_type = @type_string(field_name_a)
    b_type = @type_string(field_name_b)
    a_type? and a_type == b_type

  @first_generator_output: (generator, type_string = null) ->
    return '' unless generator?
    return @first_slot(generator.out, type_string)

  @first_generator_input: (generator, type_string = null) ->
    return '' unless generator?
    return @first_slot(generator.in, type_string)

  @first_slot: (object, type_string = null) ->
    return '' unless object?
    outputs = []
    for output_name, _ of object
      outputs.push(output_name)

    # Get a consistent order.
    outputs.sort()

    type_matcher = null
    if type_string == null
      type_matcher = new RegExp('.*')
    else
      type_matcher = new RegExp(".*_#{type_string}$")

    for output_name in outputs
      if type_matcher.test(output_name)
        return output_name

    # No matches
    return ''
