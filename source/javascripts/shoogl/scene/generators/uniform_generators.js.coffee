#
#= require_tree ./uniform
#

class namespace('shoogl.scene.generators').UniformGenerators
  constructor: (@_scene_items) ->
    @load_all_generators()
    @activate()

  load_all_generators: () =>
    @_all_uniform_generators = []
    for klass_name, klass of shoogl.scene.generators.uniform
      @_all_uniform_generators.push {name: "u#{klass_name}", generator: new klass(@_scene_items)}

  activate: (active_generator_names...) =>
    active_generator_names ||= []
    @_active_uniform_generators = {}

    for uniform_generator in @_all_uniform_generators
      generator = uniform_generator.generator
      generator_name = uniform_generator.name
      activate = active_generator_names.length == 0

      for active_generator_name in active_generator_names
        if generator_name == active_generator_name or generator.aliases.indexOf(active_generator_name) != -1
          activate = true
          generator_name = active_generator_name
          break

      @_active_uniform_generators[generator_name] = generator if activate

  generate: (uniforms) ->
    uniforms ||= {}
    for uniform_name, generator of @_active_uniform_generators
      if uniforms[uniform_name]
        uniforms[uniform_name].value = generator.generate()
      else
        uniforms[uniform_name] =
          type: generator.boxed_type
          value: generator.generate()
    return uniforms
