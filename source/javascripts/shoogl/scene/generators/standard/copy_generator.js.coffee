# Passes through a value
#
NS = namespace('shoogl.scene.generators.standard')
class NS.CopyGenerator
  constructor: () ->
    @in =
      value_f: 0
    @out =
      value_f: 0
    @name = "Copy generator"
    @description = "Copies a value"

  update: () ->
    @out.value_f = @in.value_f
