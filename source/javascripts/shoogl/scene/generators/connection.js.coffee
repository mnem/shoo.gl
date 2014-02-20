# Connect the value from output_name of
# output to the input_name field of input
NS = namespace('shoogl.scene.generators')
class NS.Connection
  constructor: (@output, @output_name, @input, @input_name) ->
    @name = "Connection"

    if @output?
      @in = @output.in
    else
      @in = {}

    if @input?
      @out = @input.out
    else
      @out = {}

    if @connection_valid()
      @description = "Feeding #{@output.name} #{@output_name} into  #{@input.name} #{@input_name}"
    else
      @description = "Invalid connection"

  update: () ->
    if @output_valid()
      @output.update()

    @copy_data()

    if @input_valid()
      @input.update()

  output_valid:() ->
    @output?.out[@output_name]?

  input_valid:() ->
    @input?.in[@input_name]?

  connection_valid: () ->
    @input_valid() and @output_valid() and shoogl.scene.generators.TypeTools.types_equal(@output_name, @input_name)

  copy_data: () ->
    if @connection_valid()
      type_string = shoogl.scene.generators.TypeTools.type_string(@output_name)
      if type_string == 'f'
        @input.in[@input_name] = @output.out[@output_name]
      else if type_string == 'v2'
        @input.in[@input_name].copy(@output.out[@output_name])
      else if type_string == 'v3'
        @input.in[@input_name].copy(@output.out[@output_name])
      else if type_string == 'v4'
        @input.in[@input_name].copy(@output.out[@output_name])
