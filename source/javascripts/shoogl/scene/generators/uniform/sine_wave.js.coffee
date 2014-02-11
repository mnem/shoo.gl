class namespace('shoogl.scene.generators.uniform').SineWave
  constructor: () ->
    @description = 'Sine wave generator.'
    @boxed_type = 'f'
    @aliases = [
    ]
    # Parameters for the value
    @hertz = {value: 1, min: 0.0001, max: 1000.0}
    @parameters = [
      'hertz'
    ]

  generate:() ->
    seconds = Date.now() / 1000
    Math.sin(seconds * @hertz.value)
