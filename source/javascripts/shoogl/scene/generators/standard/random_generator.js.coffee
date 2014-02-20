NS = namespace('shoogl.scene.generators.standard')
class NS.RandomGenerator
  constructor: () ->
    @in = {}
    @out =
      result_f: 0
    @name = "Random generator"
    @description = "Generates a random number between 0 (inclusive) and 1 (exclusive)"

  update: () ->
    @out.result_f = Math.random()
