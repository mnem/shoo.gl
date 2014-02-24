#= require shoogl/scene/generators/faux/connection
#= require shoogl/scene/generators/type_tools
#= require_tree ./standard
#= require_tree ./faux

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
    return unless name and generator_chain.length >= 1

    connectors = []

    CON = shoogl.scene.generators.faux.Connection

    forced_connections = []
    generator_a = generator_chain[generator_chain.length - 1]
    generator_b = null
    if generator_chain.length >= 2
      for i in [0...(generator_chain.length - 1)]
        if typeof(generator_chain[i]) != 'string'
          generator_a = generator_chain[i]

        if typeof(generator_chain[i + 1]) == 'string'
          forced_connections.push generator_chain[i + 1]
        else
          generator_b = generator_chain[i + 1]
          connector = new CON(generator_a, generator_b, forced_connections...)
          connectors.push(connector)
          forced_connections.length = 0

    if typeof(generator_chain[generator_chain.length - 1]) == 'string'
      forced_connections.push(generator_chain[generator_chain.length - 1])
    else
      generator_a = generator_chain[generator_chain.length - 1]

    generator_b = null

    TT = shoogl.scene.generators.TypeTools
    generator_f_output = TT.first_generator_output(generator_a, 'f')
    generator_v3_output = TT.first_generator_output(generator_a, 'v3')
    if generator_f_output
      if TT.is_array(generator_a.out[generator_f_output])
        generator_b = new shoogl.scene.generators.standard.FloatArrayDomOutputGenerator()
      else
        generator_b = new shoogl.scene.generators.standard.FloatDomOutputGenerator()
    else if generator_v3_output
      generator_b = new shoogl.scene.generators.standard.Vector3DomOutputGenerator()
    else
      console.error "Cannot show output for #{generator_a.name}", generator_a
      console.log "Cannot show output for #{generator_a.name}", generator_a

    dom_output = $("<li><h2>#{name}</h2></li>")

    if generator_b?
      connector = new CON(generator_a, generator_b, forced_connections...)
      connectors.push(connector)
      $(dom_output).append generator_b.out.output_dom

    $(@_dom_list).append dom_output

    @_items.push
      name: name
      connectors: connectors
      generator: generator_a
      generator_output: generator_f_output or generator_v3_output
      generator_type: TT.type_string(generator_f_output or generator_v3_output)

  find: (name) ->
    for item in @_items
      if item.name == name and item.connectors.length > 0
        return item.connectors[0]
    return null

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
