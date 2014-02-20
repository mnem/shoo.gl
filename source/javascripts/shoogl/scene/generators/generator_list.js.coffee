#= require shoogl/scene/generators/connection
#= require shoogl/scene/generators/type_tools
#= require_tree ./standard

NS = namespace('shoogl.scene.generators')
class NS.GeneratorList
  constructor: (@title, css_classes...) ->
    @title ||= ''
    @dom = $("<div class='generator-list'><h1>#{@title}</h1></div>")
    @dom.addClass(css_classes.join ' ') if css_classes?.length > 0
    @_dom_list = $("<ul></ul>")
    $(@dom).append @_dom_list
    @_items = []

  # Add a generator chain. At least
  # one generator and the name of the
  # output field must be specified. If
  # more than one generator appears, they
  # must appear in generator, 'output_name'
  # pairs.
  add: (name, generator_chain...) ->
    return unless name
    return unless generator_chain?.length >= 2
    return unless (generator_chain.length & 1) == 0

    connectors = []

    # Connect each generator pair
    while generator_chain.length > 2
      generator = generator_chain.shift()
      generator_output = generator_chain.shift()
      connection_fields = generator_output.split ':'
      if connection_fields.length == 1
        connection_fields.push connection_fields[0]
      connector = new shoogl.scene.generators.Connection(generator, connection_fields[0], generator_chain[0], connection_fields[1])
      connectors.push(connector)

    # Connect the final (or first) generator to
    # a dom output
    generator = generator_chain.shift()
    generator_output = generator_chain.shift()
    output = null
    type_string = shoogl.scene.generators.TypeTools.type_string(generator_output)
    if type_string == 'f'
      output = new shoogl.scene.generators.standard.FloatDomOutputGenerator()
    else if type_string == 'vec3'
      output = new shoogl.scene.generators.standard.Vector3DomOutputGenerator()
    else
      console.error "Cannot show output for #{generator_output}"

    dom_output = $("<li><h2>#{name}</h2></li>")

    if output?
      connector = new shoogl.scene.generators.Connection(generator, generator_output, output, "value_#{type_string}")
      connectors.push connector
      $(dom_output).append output.out.output_dom

    $(@_dom_list).append dom_output

    @_items.push
      name: name
      connectors: connectors
      generator: generator
      generator_output: generator_output
      generator_type: type_string

  to_three_type_object: () ->
    @_three_typed_object ||= {}
    for item in @_items
      @_three_typed_object[item.name] =
        type: item.generator_type
        value: item.generator.out[item.generator_output]

    return @_three_typed_object

  update: () ->
    for item in @_items
      for connector in item.connectors
        connector.update()
