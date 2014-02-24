# Creates a fake generator which hooks the type matching
# output values from output into the the type matching
# input values for input. A list of forced connections
# may be passed to override the automatic connection
# behaviour. For example:
#
#    Connection(gen_a, gen_b, 'result_i:value_f', 'result_f:value_i')
#
# This will force the generators to be connected as:
#
#    gen_a.result_i --> value_f.gen_b
#    gen_a.result_f --> value_i.gen_b
#
# As shorthand you may omit one of the field specifiers and
# it will be automatically filled with the first type from
# the other side. For example ':value_f' will pick the first
# float output from output and 'result_i:' will pick the
# first integer input in input.
#
NS = namespace('shoogl.scene.generators.faux')
class NS.Connection
  constructor: (@output, @input, forced_connections...) ->
    @name = "Connection"

    output_name = "<null>"
    output_name = @output.name if @output?
    input_name = "<null>"
    input_name = @input.name if @input?
    @description = "Connecting #{output_name} to #{input_name}"

    @in = {}
    @out = {}

    if @output? and @input?
      @in = @output.in
      @out = @input.out

      if forced_connections.length == 0
        @_automatch_connection()
      else
        @_create_connections(forced_connections)
    else
      @output_to_input_map = {}

  update: () ->
    @output.update() if @output?

    for out_name, in_name of @output_to_input_map
      out_type = shoogl.scene.generators.TypeTools.type_string out_name
      if out_type == 'v2' or out_type == 'v3' or out_type == 'v4'
        @input.in[in_name].copy(@output.out[out_name])
      else
        @input.in[in_name] = @output.out[out_name]

    @input.update() if @input?

  _create_connections: (connections_array) ->
    @output_to_input_map = {}
    TT = shoogl.scene.generators.TypeTools
    # Always connect timestamps
    out_timestamp = TT.first_generator_output(@output, 'timestamp')
    if out_timestamp
      connections_array.push "timestamp:"

    for pair in connections_array
      connections = pair.split ':'
      if connections.length == 2
        out_name = connections[0]
        in_name = connections[1]
        if out_name and not in_name
          type_string = TT.type_string out_name
          in_name = TT.first_generator_input(@input, type_string)
        else if not out_name and in_name
          type_string = TT.type_string in_name
          out_name = TT.first_generator_output(@output, type_string)
        else if not out_name and not in_name
          out_name = TT.first_generator_output(@output)
          type_string = TT.type_string out_name
          in_name = TT.first_generator_input(@input, type_string)

        if @output.out[out_name]? and @input.in[in_name]?
          @output_to_input_map[out_name] = in_name

  _automatch_connection: () ->
    @output_to_input_map = {}
    TT = shoogl.scene.generators.TypeTools
    for out_name, _ of @output.out
      out_type = TT.type_string out_name
      in_name = TT.first_generator_input @input, out_type
      if in_name
        @output_to_input_map[out_name] = in_name
