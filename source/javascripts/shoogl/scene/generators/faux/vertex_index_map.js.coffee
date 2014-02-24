# Creates a map from geometry vertex index
# to a value generated by the passed generator.
#
# If no generator input is specified, the first
# integer or float input will be selected.
#
# If no generator output is specified, the first
# generator output will be chosen.
#
# The type of the output index map will
# match the selected generator output. The
# type will not inherently be an array type -
# instead it describes the type of each
# component in the array. This is what is
# expected by the attributes input for a
# shader in ThreeJS.
#
# By default maps are not dynamic - that is
# the mapping will be generated once and then
# never re-generated. To change this, set the
# updates_per_second value to any positive number
# to cause the values to be regenerated.
#
NS = namespace('shoogl.scene.generators.faux')
class NS.VertexIndexMap
  constructor: (@generator, @generator_input = null, @generator_output = null) ->
    @name = "VertexIndexMap"
    if @generator?
      @description = "Creates a map from vertex index to value generated by #{@generator.name}"
    else
      @description = "Creates a map from vertex index to value"

    if not @generator_input? or not @generator?.in[@generator_input]?
      @generator_input = shoogl.scene.generators.TypeTools.first_generator_input(@generator, 'i')

    if not @generator?.in[@generator_input]?
      @generator_input = shoogl.scene.generators.TypeTools.first_generator_input(@generator, 'f')

    if not @generator_output? or not @generator.out[@generator_output]
      @generator_output = shoogl.scene.generators.TypeTools.first_generator_output(@generator)

    @in =
      source_geometry: null
      updates_per_second: 0.0

    output_type = shoogl.scene.generators.TypeTools.type_string(@generator_output)
    @_output_name = "index_map_#{output_type}"
    @out =
      last_update_timestamp: Date.now()
    @out[@_output_name] = []

    @_next_update = 0

  update: () ->
    return unless @in.source_geometry?
    return unless @generator?.out[@generator_output]?

    num_vertices = @in.source_geometry.vertices.length
    out_array = @out[@_output_name]
    needs_update = num_vertices != out_array.length
    if @in.updates_per_second > 0
      @_next_update = 0 if @_next_update != @_next_update
      now = Date.now()
      if now >= @_next_update
        needs_update = true
        period_ms = @in.updates_per_second * 1000
        update_period_ms = period_ms - (now - @_next_update)
        update_period_ms = 0 if update_period_ms < 0
        update_period_ms = period_ms if update_period_ms > period_ms
        @_next_update = now + update_period_ms
    else
      @_last_update = 0

    if needs_update
      out_array.length = num_vertices
      for i in [0...num_vertices]
        if @generator_input
          @generator.in[@generator_input] = i
        @generator.update()
        out_array[i] = @generator.out[@generator_output]
      @out.last_update_timestamp = Date.now()