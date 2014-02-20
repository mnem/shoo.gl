NS = namespace('shoogl.scene.generators.standard')
class NS.SineGenerator
  constructor: () ->
    @in =
      value_f: 0
      hertz_f: 1
    @out =
      result_f: 0
    @name = "Sine generator"
    @description = "Uses the input value and hertz frequency to generate a sine output value."

  update: () ->
    @out.result_f = Math.sin(@in.value_f * @in.hertz_f)
