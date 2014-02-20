NS = namespace('shoogl.scene.generators.standard')
class NS.TimeGenerator
  constructor: () ->
    @in = {}
    @out =
      seconds_f: 0
    @name = "Time generator"
    @description = "Seconds since 1 January 1970 00:00:00 UTC."

  update: () ->
    @out.seconds_f = Date.now() / 1000
