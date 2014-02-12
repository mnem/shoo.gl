#
#= require_tree ./uniform
#

class UniformEditControl
  constructor: (@generator) ->
    @dom_element = $("<div id='#{@generator.name}' class='panel #{@generator.generator.boxed_type}'></div>")
    $(@dom_element).append("<h1>#{@generator.name}</h1>")
    @value_holder = $("<span id='value'></span>")
    $(@dom_element).append(@value_holder)

  update: (value) ->
    text = ""
    switch @generator.generator.boxed_type
      when 'f' then @_update_f(value)
      when 'v3' then @_update_v3(value)
      else @_update_unknown(value)

  _create_float_span: () ->
    span = $('<span class="number"></span>')
    $(span).on "mouseover", (e) =>
      $(span).addClass('mouseover')
    $(span).on "mouseout", (e) =>
      $(span).removeClass('mouseover')
    return span

  _update_f: (value) ->
    if @value_holder.children().length == 0
      @value_holder.append(@_create_float_span())

    display = @value_holder.children().first()
    display.attr('title', "#{value}")
    if display.hasClass('mouseover')
      display.text("#{value}")
    else
      display.text(value.toFixed(4))

  _update_v3: (value) ->
    if @value_holder.children().length == 0
      x = @_create_float_span()
      $(x).addClass('x vector-component')
      y = @_create_float_span()
      $(y).addClass('y vector-component')
      z = @_create_float_span()
      $(z).addClass('z vector-component')
      @value_holder.append(x,y,z)

    index_map = ['x', 'y', 'z']
    @value_holder.children().each (index, item) ->
      if $(item).hasClass('mouseover')
        $(item).text("#{value[index_map[index]]}")
      else
        $(item).text(value[index_map[index]].toFixed(4))


class namespace('shoogl.scene.generators').UniformGenerators
  constructor: (@_scene_items) ->
    @dom_element = $('<ul id="uniform-generators"></ul>')
    @load_all_generators()
    @activate()

  load_all_generators: () =>
    @all_uniform_generators = []
    for klass_name, klass of shoogl.scene.generators.uniform
      @all_uniform_generators.push {name: "u#{klass_name}", generator: new klass(@_scene_items), edit_control:null}

    @_create_edit_controls()

  activate: (active_generator_names...) =>
    active_generator_names ||= []
    @_active_uniform_generators = {}

    for uniform_generator in @all_uniform_generators
      generator = uniform_generator.generator
      generator_name = uniform_generator.name
      activate = active_generator_names.length == 0

      for active_generator_name in active_generator_names
        if generator_name == active_generator_name or generator.aliases.indexOf(active_generator_name) != -1
          activate = true
          generator_name = active_generator_name
          break

      @_active_uniform_generators[generator_name] = uniform_generator if activate

  generate: (uniforms) ->
    uniforms ||= {}
    for uniform_name, uniform_generator of @_active_uniform_generators
      value = uniform_generator.generator.generate()
      uniform_generator.edit_control.update(value)
      if uniforms[uniform_name]
        uniforms[uniform_name].value = value
      else
        uniforms[uniform_name] =
          type: uniform_generator.generator.boxed_type
          value: value
    return uniforms

  _create_edit_controls: () ->
    @dom_element.empty()

    ordered_names = []
    generators = {}
    for generator in @all_uniform_generators
      ordered_names.push(generator.name)
      generators[generator.name] = generator
    ordered_names.sort()

    for name in ordered_names
      generator = generators[name]
      generator.edit_control = new UniformEditControl(generator)
      list_item = $('<li></li>')
      list_item.append(generator.edit_control.dom_element)
      @dom_element.append(list_item)
