class namespace('shoogl.scene.generators.uniform').Random
  constructor: () ->
    @description = 'Random number between 0.0 and 1.0.'
    @boxed_type = 'f'
    @aliases = [
    ]
    @parameters = [
    ]

  generate:() ->
    Math.random()
