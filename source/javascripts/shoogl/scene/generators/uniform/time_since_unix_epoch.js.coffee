class namespace('shoogl.scene.generators.uniform').TimeSinceUnixEpoch
  constructor: () ->
    @description = 'Time since 1 January 1970 00:00:00 UTC, in seconds.'
    @boxed_type = 'f'
    @aliases = [
      'iGlobalTime',
    ]
    @parameters = [
    ]

  generate:() ->
    Date.now()/1000
