# Fibonacci generator as defined in OEIS A000045:
#   http://oeis.org/A000045
#
# An index of 0 will result in 0; an index of 1
# will result in 1.
#
# The default maximum index (after which the index
# will wrap) is 46. This will result in the largest
# fibonacci number which can be contained in a 32 bit
# signed integer (1,836,311,903). You can increase this
# safely to 78 (8,944,394,323,791,464) for JavaScript,
# but you will have to ensure the uniform or attribute
# containing the value is sufficiently wide.
#
NS = namespace('shoogl.scene.generators.standard')
class NS.FibonacciGenerator
  constructor: () ->
    @in =
      index_i: 0
      maximum_index_i: 46
    @out =
      value_i: 0
    @name = "Fibonacci generator"
    @description = "Calculates the n-th Fibonacci number, where f(0) = 0 and f(1) = 1"

  update: () ->
    n = Math.floor(@in.index_i) % Math.floor(@in.maximum_index_i + 1)
    @out.value_i = @fib(n)

  fib: (n) ->
    prev = -1
    result = 1

    for i in [0..n]
      sum = result + prev
      prev = result
      result = sum

    return result
